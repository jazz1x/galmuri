# 덱 디자인 토큰

> galmuri 덱 출력용 Jobs-inspired 디자인 토큰.
> 미학적 참조만 — 구조 명칭(preset 이름)과 분리.

## 타이포그래피
- **폰트 패밀리**: SF Pro Display (제목) / SF Pro Text (본문)
- **제목 크기**: 60–72pt (풀-블리드 dark 슬라이드), 48pt (light 슬라이드)
- **부제목 크기**: 22–32pt
- **본문 크기**: 24–28pt
- **캡션 크기**: 11–14pt
- **굵기**: 제목 Medium, 본문 Regular
- **줄 간격**: 제목 1.2×, 본문 1.5×

## Emoji 정책
- Chip 과 섹션 헤더에만 허용. 슬라이드 본문 텍스트에 emoji 0개.

## 종횡비
- **16:9** (표준 와이드스크린). 4:3 또는 커스텀 비율 금지.

## 색상 팔레트

| 토큰 | Hex | 용도 |
|------|-----|------|
| `dark-bg` | `#1c1c1e` | Dark 슬라이드 배경 |
| `light-bg` | `#f5f5f7` | Light 슬라이드 배경 |
| `dark-text` | `#f5f5f7` | Dark bg 텍스트 |
| `light-text` | `#1c1c1e` | Light bg 텍스트 |
| `accent` | `#0071e3` | 핵심 용어 강조, CTA |
| `muted` | `#86868b` | 보조 텍스트, 근거 |

## 레이아웃 패턴: dark-light-dark

Open 과 Close 슬라이드는 `dark-bg`. Core 슬라이드는 `light-bg`.
preset frontmatter 에서 명시적으로 오버라이드하지 않는 한 **기본 샌드위치 패턴**.

## Parallel Rule
- Close 슬라이드 제목은 Open 슬라이드 제목과 길이·품사를 맞춤.
- 예: Open = "코드 리뷰가 왜 느릴까?" → Close = "4시간 SLA 로 해결한다."

## 시각 지시 (슬라이드별)
출력 `.md` 의 각 슬라이드에 포함:
```
**Visual**: {레이아웃 지시 — 예: "제목만, 중앙 정렬, 대형", "제목 좌 / 근거 우"}
**Background**: {dark | light}
**Accent**: {강조할 용어 혹은 "없음"}
```
