# Master Profile — «Your Name»

> Single source of truth for Job-Hunt OS. Every command reads this file.
> Update facts HERE and nowhere else.
>
> **The one rule:** nothing downstream may invent a fact that isn't in this
> file. Resumes and cover letters *select and rephrase* from here — they never
> add. If it isn't written down, it doesn't get claimed.
>
> **«angle brackets» = not yet filled.** Run `/job-hunt-os:onboard` to fill
> them conversationally, or edit this file directly.

---

## Contact & headlines

- name: «Your Name»
- title: «The job title you want to be read as — not necessarily your last one»
- email: «you@example.com»
- phone: «+1 555 555 5555»
- location: «City, Region» · «and Remote, if applicable»
- portfolio: «yoursite.com — delete this line if you don't have one»
- linkedin: «https://linkedin.com/in/you»
- years_experience: «N» (canonical — used everywhere; total career in this field)
- target_salary: «Currency + floor. Note whether to anchor to a posted band when it's higher.»
- headline: "«One sentence: role + years + what you do, in your own voice»"

### Voice lenses
> Most people need one. Add a second only if you genuinely apply to two kinds of
> role (e.g. IC designer vs. founder, engineer vs. eng manager) that need
> different framing of the same facts. Each role below carries one bullet set
> per lens.

- lenses: [default]
- lens_default: "«How you want to sound by default — e.g. 'senior IC, evidence-first'»"

### Extra application-form fields
> Optional. Things ATS forms ask for that aren't on a resume. Delete if unused.

- extra_fields:
    «field_name»: «value»

---

## Experience

> One `###` block per role, most recent first. `tags` drive JD matching.
> `metrics` are quoted verbatim downstream and must never be altered or rounded.

### «Company» — «Your Title»  («Start» – «End or present»)
tags: [«keyword», «keyword», «keyword»]
summary: «One line: what the company does and what you owned.»
metrics:
  - «A number that moved, and by how much. "Cut onboarding time 40%, from 5 days to 3."»
  - «Scope counts too: users served, team size, systems owned, revenue touched.»
bullets:
  default: "«2–4 sentences of resume-ready prose. Lead with the outcome, not the task.»"
proudest: "«Optional — the thing you'd bring up unprompted in an interview.»"
weighting: «Optional — e.g. "feature prominently" or "≤1 bullet, don't lead with it".»

### «Next role — copy the block above»

---

## Suppression rules

> Roles, projects or facts that are true but that you don't want surfaced by
> default — a dated job, a client under NDA, an employer you'd rather not
> discuss. Commands check this list before writing anything.
>
> Use the exact company/project name as written in the Experience section.

- suppress: []
- suppress_notes:
    «Company»: «Why, and whether there's an exception. e.g. "Too dated. May
    include ONE bullet if the role is a direct industry match — ask first."»

---

## Selected projects

> Interview-ready case studies in priority order — the ones you can talk about
> for two minutes without notes. This ordering drives interview prep.

1. **«Project»** — «one line: what it was, what you did, how it landed». («where»)
2. «...»

---

## Skills

> Group however suits your field. Commands lead with whichever categories match
> the job description.

- «category»: [«skill», «skill», «skill»]
- «category»: [«skill», «skill»]

---

## Education / Certifications

- **«Institution» — «Credential»**
  - dates: «Month Year – Month Year» (years-only on resumes; months for forms that demand them)
  - covers: «What it actually taught — used for "tell us about your program" fields»

### Education summary (for application forms — reused verbatim)

**Full version:**
> «2–4 sentences on what your program was and why it connects to this work.
> Forms ask this constantly; writing it once saves it every time.»

**Short version (character-limited fields):**
> «The same thing in 2 sentences.»

**One-line (resume descriptor):**
> «The same thing in one clause.»

---

## Story bank

> Raw material for behavioural interview questions. One line each is enough —
> `/job-hunt-os:mock` expands them into full STAR answers with you.

- Conflict / disagreement: «»
- Failure / what you'd do differently: «»
- Ambiguity / no clear direction: «»
- Leadership / influence without authority: «»
- Why this role / why now: «»
- Proudest shipped work: «»
