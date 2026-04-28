"""
SVG <text> 요소를 폰트 글리프 path로 변환하는 유틸리티.
cairosvg가 data: URI 폰트를 지원하지 않으므로,
텍스트를 벡터 path로 미리 변환해서 폰트 의존성을 없앱니다.
"""
import re
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen


def text_to_svg_group(font_path: str, text: str, font_size: float,
                      x: float, y: float, text_anchor: str = "middle",
                      fill: str = "#000000", letter_spacing: float = 0) -> str:
    """
    문자열을 SVG <g><path .../></g> 그룹으로 변환합니다.
    y는 SVG baseline 좌표입니다.
    """
    tt = TTFont(font_path)
    glyph_set = tt.getGlyphSet()
    cmap = tt.getBestCmap()
    hmtx = tt['hmtx'].metrics
    units_per_em = tt['head'].unitsPerEm
    scale = font_size / units_per_em

    # 각 글자의 advance width 계산
    advances = []
    for char in text:
        cid = ord(char)
        gname = cmap.get(cid)
        if gname and gname in hmtx:
            advances.append(hmtx[gname][0] * scale)
        else:
            advances.append(font_size * 0.5)  # fallback

    total_width = sum(advances) + letter_spacing * max(len(text) - 1, 0)

    # text-anchor에 따른 시작 x 계산
    if text_anchor == "middle":
        current_x = x - total_width / 2
    elif text_anchor == "end":
        current_x = x - total_width
    else:
        current_x = float(x)

    paths = []
    for i, char in enumerate(text):
        cid = ord(char)
        gname = cmap.get(cid)

        if gname and gname in glyph_set:
            pen = SVGPathPen(glyph_set)
            # 폰트 좌표계(y 위쪽) → SVG 좌표계(y 아래쪽) 변환
            tpen = TransformPen(pen, (scale, 0, 0, -scale, current_x, y))
            glyph_set[gname].draw(tpen)
            d = pen.getCommands()
            if d:
                paths.append(f'<path d="{d}" fill="{fill}"/>')

        current_x += advances[i] + letter_spacing

    return '<g>' + ''.join(paths) + '</g>'


def replace_text_with_paths(svg_content: str, font_path: str) -> str:
    """
    SVG 문자열에서 <text> 요소를 찾아 path 그룹으로 교체합니다.
    한글이 포함된 텍스트만 변환합니다.
    """
    # <text ...>content</text> 패턴 매칭 (멀티라인)
    text_pattern = re.compile(
        r'<text([^>]*)>(.*?)</text>',
        re.DOTALL
    )

    def replace_match(m):
        attrs_str = m.group(1)
        content = m.group(2).strip()

        # 한글 없으면 그대로
        if not re.search(r'[가-힣]', content):
            return m.group(0)

        # 속성 파싱
        def attr(name, default=''):
            match = re.search(rf'{name}="([^"]*)"', attrs_str)
            return match.group(1) if match else default

        x = float(attr('x', '0'))
        y = float(attr('y', '0'))
        font_size = float(attr('font-size', '16'))
        text_anchor = attr('text-anchor', 'start')
        fill = attr('fill', '#000000')
        letter_spacing = float(attr('letter-spacing', '0'))

        group = text_to_svg_group(
            font_path=font_path,
            text=content,
            font_size=font_size,
            x=x, y=y,
            text_anchor=text_anchor,
            fill=fill,
            letter_spacing=letter_spacing,
        )
        return group

    return text_pattern.sub(replace_match, svg_content)
