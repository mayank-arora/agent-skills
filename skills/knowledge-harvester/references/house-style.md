# House Style

Match the tone and structure of any docs already in the repo.

- Lead each file with a 1-3 line TL;DR.
- **Cite sources inline.** Code as `path:line`. Tickets as their tracker key (linked). Wiki/chat as links. DB facts as the query or a "(live DB, YYYY-MM-DD)" note.
- **Tag confidence.** State `verified` when checked against code or data. State `UNVERIFIED` when only asserted (a stale doc, a single chat opinion, an unconfirmed claim). Never present an assertion as fact.
- Prefer **tables** for enumerations (statuses, endpoints, entities, tickets). Prefer **concrete numbers** (real counts) over adjectives ("many", "a lot").
- No marketing tone, no fluff. Plain declarative sentences.
- Use plain hyphens, commas, and standard markdown bullets. Avoid em-dashes, arrows, tildes, section signs, and fancy bullets.
- Convert relative dates to absolute (write the actual date, not "yesterday"/"last quarter").
- Date any file that contains live-data facts and label it a point-in-time snapshot.
- When you find an existing doc already covers something, link to it rather than restating it.
- Surface limits and quirks plainly. The most useful knowledge is usually "what it does NOT do" and "where it breaks", not the happy path.
