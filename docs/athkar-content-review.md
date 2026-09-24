# Athkar content review

Draft version: `2026-09-24-draft.1`. Source comparison: 24 September 2026.

**Not approved for release.** This is an initial editorial comparison against
published hadith texts, not a scholarly authentication or a claim that the
collection is complete. The corpus retains its PLACEHOLDER warning. No entries
have qualified human approval yet.

## Corrections applied

Existing IDs, category memberships, ordering and repetition counts are preserved
in this pass so saved favourites retain their identity. Eight entries changed:

| IDs | Correction | Evidence |
| --- | --- | --- |
| mo1, ev1 | Restored the omitted continuation after the opening declaration. The morning wording substitutes day for night; this adaptation needs reviewer confirmation. Expanded the English meaning accordingly. | [Muslim 2723b](https://sunnah.com/muslim:2723b) explicitly includes the continuation and describes the corresponding morning recitation. |
| mo2 | Restored seeking refuge from one's deeds and the final statement that only Allah forgives sins. Restored the omitted covenant/promise clause in the English meaning. | [Bukhari 6306](https://sunnah.com/bukhari:6306). |
| mo5, ev4 | Changed the citation from Muslim 2691 to 2692, which explicitly describes this phrase 100 times in the morning/evening. | [Muslim 2692](https://sunnah.com/muslim:2692). |
| sl2 | Changed “gather” to “raise” in Arabic and English to match the cited narration. The count remains unresolved below. | [Abu Dawud 5045](https://sunnah.com/abudawud:5045). |
| wa2 | Restored the cited Arabic clause order: bodily health, returned soul, permission to remember. Reordered the English meaning. | [Tirmidhi 3401](https://sunnah.com/tirmidhi:3401). |
| ev2 | Replaced an overbroad English promise of protection from all harm with a contextual description of the scorpion-sting report. Aligned the Arabic description to that context. | [Muslim 2709a, in Book 48](https://sunnah.com/muslim/48), also [Arabic text and page reference](https://sounah.com/hadith/15159/). |

The Arabic supplications are historical source texts. Edited English meanings
are newly drafted from the Arabic, not imported translations. This does not
establish provenance or redistribution rights for the untouched prototype
translations; those still need review.

## Inventory and outstanding decisions

Every current ID appears below. “Compared” means an initial source comparison,
not approval. A source supporting a phrase does not necessarily establish its
selected count, occasion, wording variant or promised virtue.

| IDs | Initial comparison / next action | Source |
| --- | --- | --- |
| mo1, ev1 | Corrected; confirm full wording, vocalization and morning substitution. | [Muslim 2723b](https://sunnah.com/muslim:2723b) |
| mo2 | Corrected; review complete wording and English meaning. | [Bukhari 6306](https://sunnah.com/bukhari:6306) |
| mo3 | Compared: wording, three repetitions and morning/evening context are present. Page attributes a sahih grade to Al-Albani. | [Abu Dawud 5088](https://sunnah.com/abudawud:5088) |
| mo4 | **Unresolved:** cited Arabic has different wording and does not specify three repetitions. Page attributes a da'if grade to Al-Albani. Find and assess the exact supporting narration before changing the entry. | [Abu Dawud 5072](https://sunnah.com/abudawud:5072) |
| mo5, ev4 | Citation corrected; wording, count and occasions compared. | [Muslim 2692](https://sunnah.com/muslim:2692) |
| mo6 | Compared: phrase and count of ten are present; this report does not itself specify morning. Confirm category placement or add supporting evidence. | [Muslim 2693](https://sunnah.com/muslim:2693) |
| ev2 | Virtue description corrected. **Count of three remains unresolved** against the cited Muslim report, which does not specify three. Assess a supporting narration or revise the count after review. | [Muslim Book 48, 2709a](https://sunnah.com/muslim/48) |
| ev3 | **Unresolved wording/citation variant:** the displayed Tirmidhi report ends its evening formula with resurrection, while the app says return. Compare editions and alternative reports before selecting a correction. | [Tirmidhi 3391](https://sunnah.com/tirmidhi:3391) |
| sl1, wa1 | Compared: bedtime and waking texts occur together in the cited report. | [Bukhari 6324](https://sunnah.com/bukhari:6324) |
| sl2 | Wording corrected. **Count needs adjudication:** the report includes three repetitions, but the page's Arabic Al-Albani grading explicitly excludes that clause from its sahih assessment. | [Abu Dawud 5045](https://sunnah.com/abudawud:5045) |
| sl3, sl4, sl5 | Compared: bedtime sequence of 33, 33 and 34 appears in the report. Confirm Arabic vocalization and the explanatory virtue label. | [Bukhari 5362](https://sunnah.com/bukhari:5362) |
| wa2 | Clause order corrected. Page attributes sahih to Darussalam; report includes Tirmidhi's hasan assessment. Record chosen grading authority explicitly at final review. | [Tirmidhi 3401](https://sunnah.com/tirmidhi:3401) |
| ap1, ap2 | Initial comparison supports three requests for forgiveness followed by the peace supplication. Finish exact Arabic comparison. | [Muslim 591](https://sunnah.com/muslim:591) |
| ap3, ap4, ap5 | Detailed comparison pending: verify the chosen 33/33/33 form, its ordering, and whether a concluding formula belongs to the selected narration. Do not combine variants without recording their evidence. | [Muslim 595a](https://sunnah.com/muslim:595a) |
| mi1 | Detailed comparison pending, including support for the selected count of ten. | [Muslim 2695](https://sunnah.com/muslim:2695) |
| mi2 | Detailed comparison pending, especially whether ten is a supported count or merely an app counter target. | [Bukhari 6610](https://sunnah.com/bukhari:6610) |
| mi3 | **Unresolved:** cited report encourages blessings on the Prophet but does not establish the app's exact formula or count of ten. Do not present those as a quotation from this report. | [Tirmidhi 484](https://sunnah.com/tirmidhi:484) |
| ta1 | Detailed comparison of citation pending. Free-counter targets must be distinguished from prescribed repetition counts. | [Muslim 2691](https://sunnah.com/muslim:2691) |

## Human review record

For each entry, record the reviewer, review date, exact content version, decision,
and any corrections. Approval must cover Arabic wording and diacritics, English
meaning, references including narration variants, grading with named authority,
count, occasion, and any virtue claim. Record translation provenance and rights.
Blank fields below deliberately mean **not approved**.

- Qualified reviewer: pending
- Reviewed content version: pending
- Approved entry IDs: none
- Outstanding decisions resolved: no
- Translation/provenance review: pending
- Release approval and date: pending

This pass does not add short/complete routines or claim exhaustive coverage.
Those require a reviewed selection of content as well as the session model
described in `expanded-v1-plan.md`. Keep the placeholder guard until there is
an actual signed-off replacement; passing software tests is not content approval.

## Engineering validation for this draft

- Content, reader-controller and Home timing tests: 39 passed.
- JSON structure, unique IDs and inventory coverage: all 26 entries checked.
- Combined content/controller/timing/reader-flow/responsive run: 43 passed,
  43 failed. UI tests report a horizontal overflow in the Home header at
  `lib/features/home/home_tab.dart:128`. That file already had local changes
  and was not edited in this content pass. Visual validation of the longer
  text remains outstanding; no golden baselines were regenerated.
