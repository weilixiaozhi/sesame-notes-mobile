"""P0 PDF 字符验收：使用已有 pypdf 检查探针，不以文件生成成功代替保真验收。"""

import json
import re
import struct
import sys
from pathlib import Path

from pypdf import PdfReader


def blank_glyphs_are_empty(reader):
    """直接检查嵌入字体的空白轮廓，避免文本提取掩盖实际显示错误。"""
    checked = set()
    for page in reader.pages:
        for reference in page['/Resources']['/Font'].values():
            font = reference.get_object()
            if id(font) in checked:
                continue
            checked.add(id(font))
            descendant = font['/DescendantFonts'][0].get_object()
            mapping = descendant['/CIDToGIDMap'].get_data()
            ttf = descendant['/FontDescriptor']['/FontFile2'].get_data()
            tables = {}
            for index in range(struct.unpack_from('>H', ttf, 4)[0]):
                tag, _, offset, _ = struct.unpack_from('>4sIII', ttf, 12 + index * 16)
                tables[tag] = offset
            short = struct.unpack_from('>h', ttf, tables[b'head'] + 50)[0] == 0
            width, code = (2, '>H') if short else (4, '>I')
            cmap = font['/ToUnicode'].get_data().decode('ascii')
            for cid, unicode in re.findall(r'<([0-9a-fA-F]{4})>\s*<([0-9a-fA-F]{4,8})>', cmap):
                if int(unicode, 16) not in (9, 10, 13, 32, 160):
                    continue
                glyph = struct.unpack_from('>H', mapping, int(cid, 16) * 2)[0]
                start = struct.unpack_from(code, ttf, tables[b'loca'] + glyph * width)[0]
                end = struct.unpack_from(code, ttf, tables[b'loca'] + (glyph + 1) * width)[0]
                if start != end:
                    return False
    return bool(checked)


def main():
    directory = Path(sys.argv[1] if len(sys.argv) > 1 else "Temp/memos-p0")
    samples = json.loads((directory / "pdf-expectations.json").read_text(encoding="utf-8"))
    reader = PdfReader(directory / "probe.pdf")
    text = "".join(page.extract_text() for page in reader.pages)
    checks = {
        "only_note_content": re.sub(r"\s", "", text) == re.sub(r"\s", "", "".join(samples)),
        "long_cjk_complete": text.count("字") == 100000,
        "long_latin_complete": text.count("A") == 10000,
        "unicode_sample": samples[0] in text,
        "edge_spaces": samples[1] in text,
        "blank_paragraphs": samples[2] in text,
        "blank_glyphs_are_empty": blank_glyphs_are_empty(reader),
    }
    result = {
        "pages": len(reader.pages),
        "bytes": (directory / "probe.pdf").stat().st_size,
        "checks": checks,
    }
    # 只输出元信息，不把后续业务样本中的正文带入日志。
    print(json.dumps(result, ensure_ascii=False, indent=2))
    (directory / "pdf-result.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
    return 0 if all(checks.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())
