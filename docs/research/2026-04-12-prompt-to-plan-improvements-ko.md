# prompt-to-plan 스킬 개선 리서치 리포트

> **날짜**: 2026-04-12
> **조사 범위**: Anthropic 공식 문서 + Claude Code 생태계
> **대상**: `workflow/prompt-to-plan/SKILL.md`
> **방법**: 4개 축을 담당하는 병렬 리서치 에이전트 4대

## 요약

4개 축(① Claude 4/4.6 프롬프트 모범사례, ③ Claude Code 스킬 모범사례,
② Extended Thinking & Plan Mode, ⑤ 서브에이전트 핸드오프)을 조사한 결과,
**20개의 독립적 개선 제안**을 도출했다. 중복 제거 후 영향도순으로 정렬.

가장 임팩트가 큰 3개: **(1) few-shot 예시 추가**, **(2) HARD-GATE를 calm phrasing으로
재작성**, **(3) evals.json을 공식 스키마에 정렬**. 이 3개만 적용해도 스킬의
Claude 4.6 최적화와 공식 생태계 정합성이 크게 향상된다.

---

## 축 ①: Claude 4/4.6 프롬프트 모범사례

출처:
- [Claude 4 모범사례](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
- [프롬프트 엔지니어링 개요](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- [컨텍스트 엔지니어링 블로그](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

### 발견 1: Few-shot / Multishot 예시 누락

- **현재 상태**: SKILL.md에 before/after 변환 예시가 없음. Flipped Interaction 예시 1개만
  존재(L98-108).
- **공식 권장**: "최상의 결과를 위해 3-5개 예시를 포함하라. 예시는 `<example>` 태그로
  감싸라." — Anthropic 프롬프트 엔지니어링 가이드.
- **갭**: 티어별 구체적인 입력→출력 예시가 없으면, Claude는 기대하는 변환 품질과
  형식에 대한 참조가 없다.
- **제안**: Lite/Standard/Deep별 before/after 쌍 3개를 `<examples>` 섹션으로 추가.

### 발견 2: Claude 4.6 모델 특화 가이드 누락

- **현재 상태**: "Target Model Adaptation"(L371-376)이 구분자 스타일(XML vs Markdown)만 다룸.
  Claude 4.6 고유 주의사항 없음.
- **공식 권장**: "Claude 4.6 모델부터 마지막 어시스턴트 턴의 prefill 응답은 더 이상
  지원되지 않는다." / "처방적 단계보다 일반적 지시를 선호하라." / "Opus 4.6은
  과도한 엔지니어링 경향이 있다."
- **갭**: prefill 폐지, 과잉 엔지니어링 경향, 수동 CoT 트리거를 대체하는 적응형 사고에
  대한 안내가 없음.
- **제안**: "Target Model Adaptation"에 Claude 4.6 하위 섹션을 추가하여 이러한 행동 변화를 다룸.

### 발견 3: WHY 원칙이 부분적으로만 적용됨

- **현재 상태**: `<constraints>` 섹션(L145-149)에 "각각 WHY가 중요한지 포함"이라고 명시 — 양호.
  그러나 `<task>`와 `<role>` 템플릿 가이드에는 WHY 지시가 없음.
- **공식 권장**: "지시 뒤에 맥락이나 동기를 제공하면 Claude가 목표를 더 잘 이해한다."
  — Anthropic 프롬프트 엔지니어링.
- **갭**: WHY 원칙이 constraints뿐 아니라 모든 템플릿 섹션에 확장되어야 함.
- **제안**: `<task>` 템플릿에 "동기/배경 포함" 가이드 추가.

### 발견 4: "하지 마라가 아닌 하라" 원칙 누락

- **현재 상태**: Anti-Patterns 섹션(L346-370)에 "Do NOT" 항목 17개.
  템플릿 가이드에 긍정형 표현 선호 언급 없음.
- **공식 권장**: "하지 말라 대신 할 것을 Claude에게 알려라." — Anthropic.
- **갭**: 이 스킬이 생성하는 정제된 스펙이 부정형 표현 습관을 물려받을 수 있음.
  생성 스펙에서 긍정형 지시를 선호하라는 안내 없음.
- **제안**: 템플릿 원칙 추가: "`<constraints>`와 `<task>`에서 금지보다 긍정형 지시를 선호하라."

### 발견 5: `<example>` / `<examples>` 태그 표준 미교육

- **현재 상태**: 템플릿이 `<role>`, `<context>`, `<task>`, `<constraints>`,
  `<deliverables>`, `<acceptance_criteria>`를 사용. `<examples>` 섹션 없음.
- **공식 권장**: `<example>` / `<examples>`는 few-shot을 위한 Anthropic 표준 태그.
- **갭**: Deep 티어의 복잡한 변환 작업에서 정제 스펙에 `<examples>` 섹션을 선택적으로
  포함해야 하지만, 템플릿이 이를 언급하지 않음.
- **제안**: Deep 티어 템플릿에 선택적 `<examples>` 추가.

### 발견 6: 긴 컨텍스트 "데이터는 위에, 질의는 아래에" 원칙 미명시

- **현재 상태**: 템플릿 순서가 우연히 `<context>`를 `<task>` 위에 배치하고,
  L169에 "핵심 구현 요청을 재진술하는 최종 질의"가 하단에 있음. 양호하지만
  우연 — 설명 없음.
- **공식 권장**: "긴 데이터는 상단에 배치하라. 하단의 질의는 응답 품질을 최대 30%
  향상시킬 수 있다."
- **갭**: 태그 순서에 대한 명시적 설계 근거 없음.
- **제안**: `<context>`가 먼저이고 질의가 마지막인 이유를 설명하는 간단한 메모 추가.

### 발견 7: REFINE 단계에서 스펙 자체 검증 누락

- **현재 상태**: 플랜 자체 검토 존재(L327-329). 정제된 스펙 자체에 대한 자체 검증은
  사용자에게 제시하기 전에 없음.
- **공식 권장**: "Claude에게 자체 검증을 요청하라. '마치기 전에 [테스트 기준]에 대해
  답변을 검증하라'를 추가하라."
- **갭**: 검증 단계 없이 스펙이 사용자 의도를 놓칠 수 있음.
- **제안**: 스펙 초안 작성과 제시 사이에 자체 검증 추가:
  "제시 전에 모든 사용자 의도가 반영되었는지 확인."

### 발견 8: Claude 4.6 과잉 엔지니어링/과잉 사고 경고 누락

- **현재 상태**: L359 "단순 작업을 과도하게 명시"와 L356 "사용자가 암시하지 않은 제약 추가"가
  부분적으로 이를 다룸.
- **공식 권장**: "Opus 4.6은 추가 파일 생성, 불필요한 추상화 추가, 요청하지 않은 유연성
  구축 경향이 있다." / "이전 모델보다 훨씬 더 많은 사전 탐색을 수행한다."
- **갭**: Claude 4.6을 대상으로 하는 정제 스펙에 과잉 엔지니어링 경향을 상쇄하기 위한
  범위 제한 언어를 포함해야 한다는 명시적 경고 없음.
- **제안**: Anti-Patterns 또는 새로운 "Claude 4.6 참고사항" 섹션에 추가.

---

## 축 ③: Claude Code 스킬 모범사례

출처:
- [Claude Code 스킬 문서](https://code.claude.com/docs/en/skills)
- [에이전트 스킬 모범사례](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)

### 발견 9: description이 250자 유효 한도 초과(~770자)

- **현재 상태**: Description(L3-14)이 3개 언어의 트리거 문구를 나열하여 ~770자.
- **공식 권장**: "250자를 초과하는 설명은 스킬 목록에서 잘린다."
  — Claude Code 스킬 문서.
- **갭**: 250자 이후의 모든 내용이 스킬 디스커버리에서 보이지 않음. 토큰 낭비.
- **제안**: description을 250자 미만으로 압축. 트리거 문구는 SKILL.md 본문의 별도
  `## 활성화 트리거` 섹션으로 이동.

### 발견 10: description이 명령형, 3인칭이 아님

- **현재 상태**: L3 "Transform rough, informal user input..."
- **공식 권장**: "항상 3인칭으로 작성하라." — 스킬 모범사례.
  예시: "Processes Excel files and generates reports."
- **갭**: "Transforms..."(3인칭 -s 형태)여야 함.
- **제안**: 3인칭 현재 시제로 변경.

### 발견 11: evals.json 스키마 불일치

- **현재 상태**: `"prompt"`, `"expected_output"` + `"expectations"` 사용, `"skills"` 없음.
- **공식 권장**: 스키마는 `"query"`, `"expected_behavior"`(단일 배열), `"skills"` 사용.
- **갭**: 공식 eval 스키마와 4개 필드명 불일치.
- **제안**: evals.json을 공식 스키마에 맞게 리팩터링.

### 발견 12: HARD-GATE가 자체 anti-pattern과 모순

- **현재 상태**: `<HARD-GATE>`(L35-44)가 "NEVER execute" 사용 — 공격적 언어.
  Anti-Patterns(L366)는 "IMPORTANT:", "CRITICAL:", "YOU MUST" 사용 금지.
- **공식 권장**: "공격적 언어를 줄여라. 일반적인 프롬프팅을 사용하라."
  — Anthropic Claude 4 문서. 공식 문서에 `HARD-GATE` 패턴 없음.
- **갭**: 내부 모순. HARD-GATE가 스킬 자체 규칙을 위반.
- **제안**: `<HARD-GATE>`를 차분한 "필수 워크플로우 게이트" 섹션으로 교체.

### 발견 13: 점진적 공개(Progressive Disclosure) 미활용 — 400줄 단일 파일

- **현재 상태**: 모든 템플릿, 프로토콜, 엣지 케이스가 400줄 단일 파일에 존재.
- **공식 권장**: "SKILL.md를 500줄 이하로 유지하라. 상세 참조 자료는 별도 파일로
  분리하라." — Claude Code 스킬 문서.
- **갭**: 400줄로 한도에 근접. Deep 티어 전용 콘텐츠(리서치 프로토콜, 전체 템플릿)가
  Lite 티어 작업에서도 매번 로드됨.
- **제안**: 별도 파일로 분리: `templates.md`, `research-protocol.md`,
  `plan-conventions.md`. SKILL.md에서 참조.

### 발견 14: allowed-tools가 사용자 확인 없이 Write/Edit/Bash 허용

- **현재 상태**: L15-26에 Bash, Write, Edit이 allowed-tools에 포함.
- **공식 권장**: "allowed-tools는 Claude가 사용자 승인 요청 없이 사용할 수 있도록
  권한을 부여한다." — Claude Code 스킬 문서.
- **갭**: REFINE 단계에서는 Write/Edit/Bash가 불필요. 이들은 PLAN 실행 시에만 필요하며,
  안전을 위해 사용자 승인을 받아야 함.
- **제안**: allowed-tools에서 Write, Edit, Bash 제거. Read, Grep, Glob,
  WebSearch, WebFetch, EnterPlanMode, ExitPlanMode, AskUserQuestion만 유지.

---

## 축 ②: Extended Thinking & Plan Mode

출처:
- [Extended Thinking 문서](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
- [Adaptive Thinking 문서](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking)
- [Extended thinking 팁](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/extended-thinking-tips)
- [Claude Code 일반 워크플로우](https://code.claude.com/docs/en/common-workflows)

### 발견 15: 복잡도 티어별 사고 전략 없음

- **현재 상태**: 복잡도 분류(L80-89)가 템플릿 섹션과 리서치만 결정.
  사고 깊이 안내 없음.
- **공식 권장**: `ultrathink` 키워드는 Opus/Sonnet 4.6에서 effort를 high로 설정.
  `/effort` 명령으로 세션 전체 사고 깊이 제어(low/medium/high/max).
- **갭**: Deep 티어는 더 높은 사고 effort가 필요하지만, 스킬이 이를 안내하지 않음.
- **제안**: 복잡도 분류 테이블에 "사고 전략" 열 추가. Deep 티어에서
  `/effort high` 또는 추론 안내 프롬프트 제안.

### 발견 16: Plan Mode ↔ Extended Thinking 관계 미설명

- **현재 상태**: L74에서 `EnterPlanMode` 호출만 함. Plan Mode가 사고 행동에
  무엇을 하는지 설명 없음.
- **공식 권장**: Plan Mode는 읽기 전용 커스텀 프롬프트 모드. Extended thinking은
  기본 활성화되며 적응형 깊이를 가짐. 독립적 기능.
- **갭**: 사용자가 Plan Mode가 더 깊은 사고를 활성화한다고 생각할 수 있음. 실제로는 아님.
- **제안**: Plan Mode Transition 섹션에 관계를 명확히 하는 간단한 메모 추가.
  Deep 티어에서는 Plan Mode 진입 후 추론 안내 프롬프트 추가.

### 발견 17: 사고 관련 anti-pattern 누락

- **현재 상태**: 생성 스펙의 사고 트리거에 대한 안내 없음.
- **공식 권장**: "think", "think hard"는 Claude 4.6에서 일반 프롬프트 지시이며,
  사고 예산 할당기가 아님. "처방적 단계보다 일반적 지시를 선호하라."
- **갭**: 사용자의 원본 프롬프트에 "think step by step"이 포함될 수 있음 — 스킬이
  이를 결과 지향적 안내로 제거 또는 교체해야 함.
- **제안**: anti-pattern 추가: "정제 스펙에 'think step by step'이나 'think hard'를
  포함하지 마라 — 결과 지향적 안내를 선호하라."

### 발견 18: 리서치 프로토콜에서 인터리브드 사고 미활용

- **현재 상태**: 도메인 리서치 프로토콜(L205-237)이 최대 3회 WebSearch 쿼리를
  검색 간 반성 안내 없이 실행.
- **공식 권장**: 적응형 사고는 도구 호출 간 인터리브드 사고를 활성화.
  "도구 결과를 받은 후, 품질을 신중히 검토하고 최적의 다음 단계를 결정하라."
- **갭**: 순차적 맹목 검색이 이전 결과 기반으로 쿼리를 개선할 기회를 놓침.
- **제안**: 리서치 프로토콜에 추가: "각 WebSearch 결과 후, 다음 쿼리를 결정하기 전에
  발견 사항을 반영하라."

---

## 축 ⑤: 서브에이전트 핸드오프 패턴

출처:
- [서브에이전트 문서](https://code.claude.com/docs/en/sub-agents)
- [스킬 문서](https://code.claude.com/docs/en/skills)
- [멀티에이전트 조율 패턴](https://claude.com/blog/multi-agent-coordination-patterns)

### 발견 19: 핸드오프 메커니즘 모호 (Skill 도구 vs Agent 도구)

- **현재 상태**: L337-345에서 "subagent-dev 스킬 호출"이라고만 함. 방법 미지정.
- **공식 권장**: 스킬은 Skill 도구를 통해 인라인 실행(컨텍스트 상속). 서브에이전트는
  Agent 도구를 통해 격리 실행. `context: fork`는 스킬을 격리된 컨텍스트에서 실행.
- **갭**: subagent-dev를 Skill 도구로 호출하면 모든 REFINE 단계 컨텍스트를 상속 —
  subagent-dev 자체의 "작업별 새 컨텍스트" 원칙과 모순.
- **제안**: 핸드오프를 명확히: "플랜을 파일로 저장 → 사용자에게
  `/subagent-dev <plan-file-path>` 실행을 안내. 또는 subagent-dev에
  `context: fork` 설정."

### 발견 20: 병렬 디스패치에 `isolation: worktree` 미언급

- **현재 상태**: subagent-dev가 "병렬 구현 서브에이전트 = 충돌"을 Red Flag로 경고.
  완화 전략 없음.
- **공식 권장**: `isolation: worktree`는 각 서브에이전트에게 격리된 저장소 사본을 제공.
  변경 없으면 worktree 자동 정리.
- **갭**: 공식 기능이 스킬이 경고하는 파일 충돌 문제를 직접 해결. 현재 병렬 구현이
  불필요하게 금지됨.
- **제안**: 병렬 구현 작업을 위한 `isolation: worktree` 안내 추가.
  (참고: 이것은 주로 subagent-dev 개선이며, 핸드오프 컨텍스트 인지를 위해 여기 언급.)

---

## 개선 제안 — 우선순위 매트릭스

| # | 제안 | 영향도 | 난이도 | 축 |
|---|------|--------|--------|---|
| 1 | Lite/Standard/Deep별 few-shot before/after 예시 3개 추가 | **높음** | 중간 | ① |
| 2 | `<HARD-GATE>`를 차분한 "필수 워크플로우 게이트"로 교체 | **높음** | 쉬움 | ①③ |
| 3 | evals.json을 공식 스키마에 맞게 리팩터링 | **높음** | 쉬움 | ③ |
| 4 | description을 250자 미만으로 압축, 트리거를 본문으로 이동 | **높음** | 쉬움 | ③ |
| 5 | Claude 4.6 모델 특화 참고사항 추가 (과잉엔지니어링, prefill 등) | **높음** | 중간 | ①② |
| 6 | REFINE 단계에 스펙 자체 검증 단계 추가 | **높음** | 쉬움 | ① |
| 7 | 점진적 공개 파일로 분리 (templates, research, plan) | **중간** | 중간 | ③ |
| 8 | 사고 관련 anti-pattern 추가 | **중간** | 쉬움 | ② |
| 9 | allowed-tools에서 Write/Edit/Bash 제거 | **중간** | 쉬움 | ③ |
| 10 | description을 3인칭 형태로 수정 | **중간** | 쉬움 | ③ |
| 11 | 템플릿 가이드에 "긍정형 지시" 원칙 추가 | **중간** | 쉬움 | ① |
| 12 | `<task>` 템플릿에 WHY 원칙 추가 (`<constraints>`뿐 아니라) | **중간** | 쉬움 | ① |
| 13 | Deep 티어 템플릿에 선택적 `<examples>` 섹션 추가 | **중간** | 쉬움 | ① |
| 14 | 복잡도 분류 → 사고 전략 매핑 추가 | **중간** | 쉬움 | ② |
| 15 | subagent-dev 핸드오프 메커니즘 명확화 | **중간** | 쉬움 | ⑤ |
| 16 | 템플릿에 태그 순서 근거 설명 코멘트 추가 | **낮음** | 쉬움 | ① |
| 17 | Plan Mode Transition에 extended thinking 관계 2줄 메모 추가 | **낮음** | 쉬움 | ② |
| 18 | 리서치 프로토콜에 반성 프롬프트 1줄 추가 | **낮음** | 쉬움 | ② |
| 19 | Execution Handoff 참고에 `isolation: worktree` 언급 | **낮음** | 쉬움 | ⑤ |
| 20 | 복잡도 분류 각주에 `/effort` 팁 추가 | **낮음** | 쉬움 | ② |

---

## SKILL.md Diff 제안

아래는 각 제안에 대한 구체적 텍스트 변경안이다. 각각 독립적으로 채택/기각 가능.

### Diff 1: Few-shot 예시 (제안 #1)

L108 이후(Flipped Interaction Pattern 섹션 끝) 삽입:

```markdown
## 변환 예시

<examples>

<example>
**티어: Lite**

원본 입력:
> Fix the login button color. It should be blue not gray.

정제된 스펙:
<task>로그인 폼 컴포넌트에서 로그인 버튼 배경색을 회색에서 파란색(#2563EB)으로
변경한다.</task>
<deliverables>
- 수정: `src/components/LoginForm.tsx` (버튼 스타일)
- 검증: 로그인 페이지에 파란색 버튼이 렌더링됨
</deliverables>
</example>

<example>
**티어: Standard**

원본 입력:
> 다크모드 추가하고 싶어

정제된 스펙:
<context>
프로젝트는 React + Tailwind CSS 기반. 현재 라이트 모드만 지원.
CSS custom properties를 사용하면 테마 전환이 용이함.
</context>
<task>CSS custom properties 기반 다크모드 토글 기능을 구현한다.
사용자의 OS 설정을 기본값으로 감지하고, 수동 토글도 지원한다.</task>
<constraints>
- Tailwind dark: variant 활용 — 기존 클래스 시스템과 일관성 유지
- localStorage에 선호 테마 저장 — 페이지 새로고침 후에도 유지
- 전환 시 깜빡임(FOUC) 방지 — 초기 로드 시 `<script>`로 클래스 적용
</constraints>
<deliverables>
- 생성: `src/hooks/useTheme.ts` (테마 상태 관리 훅)
- 수정: `src/App.tsx` (테마 provider 래핑)
- 수정: `tailwind.config.js` (darkMode: 'class')
- 생성: `src/components/ThemeToggle.tsx`
- 테스트: `tests/useTheme.test.ts`
</deliverables>
</example>

<example>
**티어: Deep**

원본 입력:
> マイクロサービスアーキテクチャへの移行戦略を設計して

정제된 스펙:
<role>
분산 시스템 아키텍트로서, 모놀리스에서 마이크로서비스로의 단계적 이전을 설계한다.
대규모 트래픽 환경에서의 실무 경험을 가진 시점에서 조언한다.
</role>
<context>
현행 시스템은 Django monolith (Python 3.11), PostgreSQL 15, Redis.
월간 활성 사용자 약 50만 명. 배포 빈도는 주 1회.
팀은 5명의 백엔드 엔지니어. Kubernetes 환경 보유.
</context>
<task>
Strangler Fig 패턴을 활용한 단계적 마이크로서비스 이전 계획을 수립한다.
Phase 1에서 인증 서비스 분리, Phase 2에서 사용자 관리, Phase 3에서 알림 서비스를 대상으로 한다.
</task>
<constraints>
- 이전 중에도 서비스 무중단 유지 — SLA 99.9% 요건
- 서비스 간 통신은 gRPC 기본, 비동기 처리는 Kafka — 팀 기존 스킬과의 정합
- 각 Phase는 독립 배포 가능 — 롤백 용이성 확보
- 데이터베이스는 단계적 분리(shared DB → 스키마 분리 → 독립 DB) — 데이터 정합성 리스크 최소화
</constraints>
<deliverables>
- 각 phase별 Architecture Decision Record (ADR)
- 서비스 경계 다이어그램 (Mermaid)
- API 계약 정의 (protobuf)
- Phase별 마이그레이션 런북
- 롤백 절차
- 모니터링/알림 설정 (Prometheus + Grafana 대시보드)
</deliverables>
<acceptance_criteria>
- Phase 1 완료 후, 인증 레이턴시 p99 < 200ms 유지
- 이전 중 에러율 0.1% 미만
- 각 서비스가 독립적으로 CI/CD 파이프라인 보유
- 카나리 배포로 단계적 릴리스 가능
</acceptance_criteria>

위 이전 계획을, 각 Phase의 구현 태스크 레벨까지 상세화해 주세요.
</example>

</examples>
```

### Diff 2: HARD-GATE를 차분한 표현으로 교체 (제안 #2)

L35-44 교체:

**기존:**
```
<HARD-GATE>
NEVER execute the user's original rough prompt directly. Always:
1. Analyze and structure into a refined implementation spec
2. Show the refined spec to the user
3. Get explicit approval before proceeding
4. Enter Plan Mode and create an implementation plan

The transformation step IS the value. Skipping it defeats the purpose.
Skipping Plan Mode defeats the purpose. Both gates are mandatory.
</HARD-GATE>
```

**변경:**
```
## 필수 워크플로우 게이트

이 스킬에는 두 개의 양보할 수 없는 게이트가 있다. 어느 하나를 건너뛰면 스킬의 목적이 무효화된다.

1. **정제 게이트** — 원본 입력을 분석하고 정제된 스펙으로 구조화한다.
   사용자에게 제시한다. 명시적 승인 없이 진행하지 않는다.
2. **Plan Mode 게이트** — 승인 후, Plan Mode에 진입하고 구현 계획을 작성한다.
   Plan Mode를 건너뛰지 않는다.

변환 단계가 핵심 가치다. 원본 프롬프트가 들어가면, 구조화된 스펙이 나온다.
원본 프롬프트를 직접 실행하면 전체 스킬을 우회하게 된다.
```

### Diff 3: evals.json 리팩터링 (제안 #3)

`evals/evals.json` 전체 교체:

```json
{
  "skill_name": "prompt-to-plan",
  "evals": [
    {
      "skills": ["prompt-to-plan"],
      "query": "다크모드 추가하고 싶어. 정리해서 플랜 만들어줘.",
      "files": [],
      "expected_behavior": [
        "Standard 티어로 분류",
        "Flipped Interaction 패턴으로 확인 질문",
        "정제 스펙에 <context>, <task>, <constraints>, <deliverables> 포함",
        "모든 콘텐츠가 한국어(입력 언어와 일치)",
        "계획 수립 전 승인 대기",
        "승인 후 EnterPlanMode 호출",
        "플랜이 write-plan 규칙 준수 (체크박스 단계, TDD, 플레이스홀더 없음)"
      ]
    },
    {
      "skills": ["prompt-to-plan"],
      "query": "Fix the login button color. It should be blue not gray.",
      "files": [],
      "expected_behavior": [
        "Lite 티어로 분류",
        "Flipped Interaction 없음 (의도 명확)",
        "정제 스펙이 <task>와 <deliverables>만 사용",
        "플랜에 1-3개 소규모 태스크",
        "EnterPlanMode 호출"
      ]
    },
    {
      "skills": ["prompt-to-plan"],
      "query": "マイクロサービスアーキテクチャへの移行戦略を設計して、実装プランまで作って",
      "files": [],
      "expected_behavior": [
        "Deep 티어로 분류",
        "WebSearch 쿼리 2-3회 실행",
        "리서치 결과가 <context>에 포함",
        "<acceptance_criteria> 포함 모든 섹션 존재",
        "콘텐츠가 일본어",
        "What Changed 요약이 일본어",
        "플랜이 10개 이상 태스크로 단계화",
        "EnterPlanMode 호출"
      ]
    }
  ]
}
```

### Diff 4: description 압축 (제안 #4)

L2-14 frontmatter description 교체:

**기존:**
```yaml
description: |
  Transform rough, informal user input into optimally structured prompts, then enter
  Plan Mode to create actionable implementation plans from the refined output.
  Use this skill whenever the user says "refine and plan", "clean up this prompt
  and make a plan", "turn this into a plan", "prompt to plan", "/prompt-to-plan",
  "refine this into a plan", "help me structure this and plan it",
  "프롬프트 정리하고 플랜 만들어줘", "이거 정리해서 계획 세워줘",
  "정리해서 플랜", "프롬프트 정리해줘",
  "プロンプト整理してプラン作って", "このアイデアを整理して実装計画を",
  "整理してプラン作って".
  Do NOT auto-trigger on every user message — only when prompt refinement + planning
  is explicitly requested.
```

**변경:**
```yaml
description: |
  Transforms rough user input into structured implementation specs, then enters
  Plan Mode to build actionable plans. Triggers on "refine and plan",
  "prompt to plan", "정리해서 플랜", "整理してプラン". Only when explicitly requested.
```

그 다음 SKILL.md 본문(frontmatter 이후, 첫 번째 섹션 전)에 추가:

```markdown
## 활성화 트리거

이 스킬은 사용자가 프롬프트 정제 + 계획 수립을 명시적으로 요청할 때 활성화된다:
- 영어: "refine and plan", "clean up this prompt and make a plan", "turn this into a plan", "prompt to plan", "refine this into a plan", "help me structure this and plan it"
- 한국어: "프롬프트 정리하고 플랜 만들어줘", "이거 정리해서 계획 세워줘", "정리해서 플랜", "프롬프트 정리해줘"
- 일본어: "プロンプト整理してプラン作って", "このアイデアを整理して実装計画を", "整理してプラン作って"

모든 사용자 메시지에 자동 트리거하지 않는다.
```

### Diff 5: Claude 4.6 모델 참고사항 (제안 #5)

L371-376 "Target Model Adaptation" 교체:

**기존:**
```markdown
## Target Model Adaptation

- **Default (Claude)**: Use XML tags as shown above
- **OpenAI (GPT)**: Switch to Markdown headers (`# Role`, `## Task`, etc.)
- **Other models**: Use Markdown headers as universal fallback

Detect if the user mentions a target model and adjust delimiter style accordingly.
```

**변경:**
```markdown
## 대상 모델 적응

- **기본값 (Claude)**: 위에 표시된 대로 XML 태그 사용
- **OpenAI (GPT)**: 마크다운 헤더로 전환 (`# Role`, `## Task` 등)
- **기타 모델**: 범용 폴백으로 마크다운 헤더 사용

사용자가 대상 모델을 언급하면 감지하여 구분자 스타일을 조정한다.

### Claude 4.6 참고사항

정제된 스펙이 Claude 4.6(기본값)에서 실행될 경우:

- **Prefill 없음**: 마지막 어시스턴트 턴의 prefill 응답은 더 이상 지원되지 않음.
  대신 명시적 지시를 사용한다.
- **과잉 엔지니어링 경향**: Opus 4.6은 추가 파일 생성, 불필요한 추상화 추가,
  요청하지 않은 유연성 구축 경향이 있음. `<task>`에 명확한 범위 경계를 포함:
  "지정된 것만 구현, 추가 기능이나 추상화 없음."
- **과잉 사고 경향**: Opus 4.6은 이전 모델보다 훨씬 더 많은 사전 탐색을 수행.
  원본 프롬프트에 "be thorough"나 "think about everything"이 있으면 약화 또는
  제거 — 과도한 탐색을 유발.
- **일반적 > 처방적**: "트레이드오프를 깊이 생각하라"가 수동으로 작성한
  단계별 분석 계획보다 더 나은 추론을 생성.
  `<task>`에서 목표와 제약을 명시; 접근 방식은 모델이 결정하도록 여유를 남긴다.
- **범위 통제**: 정제 스펙은 범위 안에 있는 것뿐 아니라 범위 밖에 있는 것도
  명시적으로 기술해야 함. 이는 과잉 엔지니어링 경향을 상쇄.
```

### Diff 6: 스펙 자체 검증 (제안 #6)

Phase 1의 현재 4단계와 5단계 사이(L67 이후, L68 이전) 삽입:

```markdown
4b. **제시 전 자체 검증** — 스펙을 보여주기 전에 확인:
   - 원본 입력의 모든 의도가 스펙의 한 섹션에 매핑됨
   - 요구사항이 명확화를 넘어 누락되거나 변경되지 않았음
   - `<context>`에 기술된 가정이 합리적 기본값임
   이 검증은 무음 — 사용자에게 알리지 않는다.
```

### Diff 7: 점진적 공개 (제안 #7)

구조적 변경 — SKILL.md를 다음으로 분리:
- `SKILL.md` — 핵심 워크플로우, 분류, anti-pattern (~200줄)
- `templates.md` — Full/Standard/Lite XML 템플릿 (L120-201)
- `research-protocol.md` — 도메인 리서치 프로토콜 + 쿼리 패턴 (L203-237)
- `plan-conventions.md` — 플랜 문서 헤더, 태스크 구조, 플랜 규칙 (L265-330)

SKILL.md에서 참조:
```markdown
## 템플릿
티어별 XML 템플릿은 [templates.md](templates.md) 참조.

## 리서치 프로토콜 (Deep 티어 전용)
WebSearch 패턴은 [research-protocol.md](research-protocol.md) 참조.

## 플랜 규칙
플랜 문서 구조는 [plan-conventions.md](plan-conventions.md) 참조.
```

### Diff 8: 사고 관련 anti-pattern (제안 #8)

Anti-Patterns 섹션(L370 이후) 추가:

```markdown
- 정제 스펙에 "think step by step"이나 "think hard"를 포함하는 것 — Claude 4.6에서는
  일반 프롬프트 텍스트이며, 사고 예산 제어가 아님. 결과 지향적 안내를 선호
  ("트레이드오프 평가", "엣지 케이스 식별")
- `<task>`에서 구현 단계를 과도하게 처방하는 것 — 적응형 사고에서는 일반적 지시가
  수동 작성된 단계별 계획보다 더 나은 추론을 생성
```

### Diff 9: allowed-tools에서 Write/Edit/Bash 제거 (제안 #9)

L15-26 교체:

**기존:**
```yaml
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Write
  - Edit
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
```

**변경:**
```yaml
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - AskUserQuestion
  - EnterPlanMode
  - ExitPlanMode
```

### Diff 10: 3인칭 description (제안 #10)

Diff 4에서 이미 반영됨 — description이 "Transforms"(3인칭)로 시작.

### Diff 11: 긍정형 지시 원칙 (제안 #11)

L149 `</constraints>` 설명 이후 템플릿 가이드에 추가:

```markdown
제약 작성 시, 금지보다 긍정형 지시를 선호:
- 대신: "인라인 스타일 사용하지 마라"
- 이렇게: "모든 스타일링에 CSS 모듈을 사용하라"
```

### Diff 12: `<task>`에 WHY 추가 (제안 #12)

L136-142 `<task>` 템플릿 가이드 수정:

**기존:**
```
<task>
[명확하고 구체적인 구현 지시.
 - 하나의 주요 동작 동사 (build, create, refactor, migrate)
 - 생성 또는 수정할 파일
 - 명시적 범위: 포함할 것 AND 제외할 것
 - 다단계일 경우 번호 매긴 목록으로 순차 단계]
</task>
```

**변경:**
```
<task>
[명확하고 구체적인 구현 지시.
 - 이 작업이 왜 중요한지 (동기/배경 1문장)
 - 하나의 주요 동작 동사 (build, create, refactor, migrate)
 - 달성할 것 (단계별 절차가 아닌 목표)
 - 명시적 범위: 포함할 것 AND 제외할 것]
</task>
```

### Diff 13: Deep 티어 템플릿에 선택적 `<examples>` (제안 #13)

전체 템플릿(Deep 티어)의 `<acceptance_criteria>` 이후(L167) 추가:

```xml
<examples> (선택 — 복잡한 변환, 분류, 형식 변환 작업에서 구체적 데모가
도움될 때 포함)
<example>
[기대하는 변환을 보여주는 입력 → 출력 쌍]
</example>
</examples>
```

### Diff 14: 복잡도 분류에 사고 전략 추가 (제안 #14)

복잡도 분류 테이블(L85-89) 교체:

**기존:**
```
| 티어 | 신호 | 사용 섹션 | 리서치? | 플랜 깊이 |
|------|------|----------|---------|----------|
| **Lite** | 단일 파일 변경, 명확한 의도 | `task` + `deliverables` | 없음 | 1-3 태스크 |
| **Standard** | 다중 파일, 약간의 모호성 | `role` + `context` + `task` + `constraints` + `deliverables` | 없음(요청 시 제외) | 4-10 태스크 |
| **Deep** | 복잡한 아키텍처, 높은 중요도, 모호한 범위 | 모든 섹션 + `acceptance_criteria` | 있음(타당 시) | 10+ 태스크, 단계화 |
```

**변경:**
```
| 티어 | 신호 | 사용 섹션 | 리서치? | 플랜 깊이 | 추론 안내 |
|------|------|----------|---------|----------|----------|
| **Lite** | 단일 파일 변경, 명확한 의도 | `task` + `deliverables` | 없음 | 1-3 태스크 | 불필요 |
| **Standard** | 다중 파일, 약간의 모호성 | `role` + `context` + `task` + `constraints` + `deliverables` | 없음(요청 시 제외) | 4-10 태스크 | 기본 적응형 |
| **Deep** | 복잡한 아키텍처, 높은 중요도, 모호한 범위 | 모든 섹션 + `acceptance_criteria` + 선택적 `examples` | 있음(타당 시) | 10+ 태스크, 단계화 | Plan Mode에서 결과 지향적 안내 (예: "아키텍처 트레이드오프와 엣지 케이스를 평가") |
```

### Diff 15: 명확한 핸드오프 메커니즘 (제안 #15)

L336-345 "실행 핸드오프" 교체:

**기존:**
```markdown
> **플랜 완료. 두 가지 실행 옵션:**
>
> **1. 서브에이전트 기반 (권장)** — 태스크별 새 서브에이전트, 태스크 간 리뷰
>
> **2. 인라인 실행** — 이 세션에서 체크포인트와 함께 태스크 순차 실행
>
> **어떤 방식으로?**

- 서브에이전트 기반 -> subagent-dev 스킬 호출
- 인라인 실행 -> 태스크를 순차 실행
```

**변경:**
```markdown
> **플랜 완료.** `docs/plans/<feature>.md`에 저장됨.
>
> **두 가지 실행 옵션:**
>
> **1. 서브에이전트 기반 (권장)** — 태스크별 새 서브에이전트, 태스크 간 리뷰.
>    실행: `/subagent-dev docs/plans/<feature>.md`
>
> **2. 인라인 실행** — 이 세션에서 체크포인트와 함께 태스크 순차 실행.
>
> **어떤 방식으로?**

- 서브에이전트 기반 → 사용자가 `/subagent-dev <plan-path>` 실행 (클린 컨텍스트 보장)
- 인라인 실행 → 현재 세션에서 태스크를 순차 실행
```

### Diff 16-20 (낮은 영향도 — 선택사항)

영향도가 낮은 소규모 추가. 완전성을 위해 포함하며,
다른 변경과 번들하지 않는 한 보류 권장:

- **Diff 16**: 태그 순서 근거를 설명하는 코멘트를 템플릿에 추가
- **Diff 17**: Plan Mode Transition에 extended thinking 관계 2줄 메모 추가
- **Diff 18**: 리서치 프로토콜에 반성 프롬프트 1줄 추가
- **Diff 19**: Execution Handoff 참고에 `isolation: worktree` 언급
- **Diff 20**: 복잡도 분류 각주에 `/effort` 팁 추가

---

## 부록: 출처

### Anthropic 공식
- [Claude 4 모범사례](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
- [프롬프트 엔지니어링 개요](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- [컨텍스트 엔지니어링 블로그](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Claude Code 스킬 문서](https://code.claude.com/docs/en/skills)
- [에이전트 스킬 모범사례](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Extended Thinking 문서](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
- [Adaptive Thinking 문서](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking)
- [Extended thinking 팁](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/extended-thinking-tips)
- [Claude Code 일반 워크플로우](https://code.claude.com/docs/en/common-workflows)
- [서브에이전트 문서](https://code.claude.com/docs/en/sub-agents)
- [멀티에이전트 조율 패턴](https://claude.com/blog/multi-agent-coordination-patterns)
- [에이전트 SDK로 에이전트 구축](https://claude.com/blog/building-agents-with-the-claude-agent-sdk)

### 커뮤니티 (검증됨, 보강 참조 목적만)
- [Plan Mode란 무엇인가? — Armin Ronacher](https://lucumr.pocoo.org/2025/12/17/what-is-plan-mode/)
- [Claude Code 사고 트리거 — kentgigger.com](https://kentgigger.com/posts/claude-code-thinking-triggers)
