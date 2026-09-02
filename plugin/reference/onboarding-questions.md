# Onboarding interview script

Read by `/job-hunt-os:onboard`. Edit this file to change what gets asked — no
skill logic needs to change.

## Principles

1. **Ask only what's still `«»`.** Anything the resume already answered is
   confirmed in a batch, not re-asked one at a time.
2. **One question at a time.** Never present a wall of questions. Wait for the
   answer, write it, move on.
3. **Highest leverage first.** If someone quits after five questions they
   should still have a usable profile.
4. **Never fill a gap yourself.** An unanswered question stays `«»`. Inventing
   a plausible-sounding metric is the single worst failure this system can have.
5. **Offer the exit.** Sections 8–10 are explicitly skippable and can be
   completed later.

---

## 1. Contact & links — *confirm, don't ask*

Show what was extracted as a single block and ask for corrections:

> Here's what I pulled from your resume — tell me anything that's wrong:
> name / title / email / phone / city / portfolio / LinkedIn

Two things worth asking even when the resume looks complete:

- **Title:** "Is «extracted title» how you want to be read, or are you aiming
  at something different?" People's last title and their target title diverge
  more often than not, and the target is what belongs here.
- **Location line:** "Do you want your city shown, remote-only, or both?"

---

## 2. Target role → drives job discovery

- "What exact job titles are you going after? Give me the real strings you'd
  search for." *(Prompt with variants: the same job is posted under three or
  four different titles, and missing one costs real listings.)*
- "Any titles you never want to see?" *(Common answers: management titles when
  you want IC, or senior titles when you're deliberately targeting mid-level.)*
- "What seniority band fits — how many years do you want postings scoped to?"

---

## 3. Location & work authorisation posture

- "Remote, hybrid, onsite, or some combination?"
- "Which countries or regions will you actually take work in?"
- "Are you open to roles outside your own country — and if so, do you have work
  authorisation there, or would it be contract work?"
- "How far outside your timezone can you realistically work?"

> Record the *posture*, not a claim. Never write anything into the profile that
> asserts a residency or authorisation the user hasn't stated. Application
> forms ask about authorisation directly and the user answers those themselves.

---

## 4. Compensation

- "What's your floor — the number below which you'd rather not see the posting?"
- "What are you actually targeting?"
- "Which currency?"
- "If a posting lists a band above your target, should we anchor to their band?"
  *(Almost always yes; ask because the alternative costs money.)*

---

## 5. Per-role metrics — **the most important questions here**

For each role, in order. This is where profile quality is won or lost: a resume
of responsibilities reads like everyone else's; a resume of outcomes doesn't.

> "For «role at company» — what changed because you were there? Ideally a
> number: a percentage, a count, a dollar figure, time saved."

If the answer is vague ("improved the experience", "made things faster"), ask
**once more**, concretely:

> "Can we put a number on that? Even a rough one you'd defend in an interview —
> before and after, how many people it reached, how long it used to take."

If there's still no number, **do not invent one**. Capture scope instead, which
is honest and still concrete:

> "No problem — then let's capture size. How many users/customers did it touch?
> How big was the team? What did you own end to end?"

Then, per role:

- "What did you personally own, versus what the team did?" *(Guards against
  claims that collapse under interview follow-up.)*
- "Anything here you'd bring up unprompted — the thing you're proudest of?"

---

## 6. Voice lenses

- "Do you apply to one kind of role, or two quite different kinds?"

One kind → keep `lenses: [default]` and move on. Two → get one sentence
describing each, then generate both bullet sets per role:

- "Describe each in a sentence — how do you want to come across in each case?"

---

## 7. Suppression rules

> "Is there anything true on here you'd rather *not* lead with? A job that's too
> dated, a client under NDA, a project you've moved past?"

For each, record whether it's an absolute exclusion or has an exception:

> "Never include it, or include it only when the role is a direct match?"

---

## 8. Selected projects — *skippable*

> "Which 3–6 pieces of work could you talk about for two minutes with no notes?
> Put them in the order you'd want to be asked about them."

---

## 9. Education — *skippable*

- Institutions, credentials, exact months *(forms ask for months; resumes don't)*.
- Then, once: "In a few sentences, what was your programme actually about and
  how does it connect to the work you do now?" → produces the full / short /
  one-line versions that get reused verbatim on every application form.

---

## 10. Story bank — *explicitly skippable*

Offer the exit first:

> "Last section — six behavioural-interview prompts. One line each is plenty,
> and you can skip this entirely and build it up later with
> `/job-hunt-os:mock`. Want to do them now?"

If yes, one line each: conflict · failure · ambiguity · leadership ·
why this role · proudest work.

---

## Closing report

Always end with:

- what's filled, and what's still `«»`
- a **profile strength** read: how many roles carry a real metric, out of how
  many roles. Say it plainly — "3 of your 4 roles have a number attached; the
  «company» one doesn't yet" — because that ratio predicts resume quality more
  than anything else here.
- the next command to run
