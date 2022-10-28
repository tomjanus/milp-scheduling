---
# Structure of a git commit message:
[Source document: ](https://dev.to/wordssaysalot/art-of-writing-a-good-commit-message-56o7)

> ### Commit message:
> * type(scope): subject
> * body (optional)
> * footer (optional)
---
## Types of commits:
* **feat** - a new feature
* **fix** - a bug fix
* **docs** - changes in documentation
* **style** - everything related to styling
* **refactor** - code changes that neither fixes a bug or adds a feature
* **test** - everything related to testing
* **chore** - updating build tasks, package manager configs, etc
---
## Scope:
A scope MUST consist of a noun describing a section of the codebase affected by the changes (or simply the epic name) surrounded by parenthesis.

> e.g.\
> feat(claims)\
> fix(orders)
---
## Subject - MANDATORY:
A short description of the changes made. It shouldn't be greater than **50 characters**, should begin with a capital letter and written in the imperative eg. Add instead of Added or Adds.

> e.g.\
> feat(claims): add claims detail page\
> fix(orders): validation of custom specification
---
## Body - OPTIONAL
The body is used to explain what changes you made and why you made them. 
- Separate the subject from the body with a blank line
- Limit each line to **72 characters**
- Do not assume the reviewer understands what the original problem was, ensure you add it
- Do not think your code is self-explanatory

> e.g.\
> refactor!: drop support for Node 6 \
> BREAKING CHANGE: refactor to use JavaScript features not available in Node 6.
---
## Footer - OPTIONAL
The footer is also optional and mainly used when you are using an **issue tracker** to the issues (issue IDs) affected by the code changes or comment to another developers or testers.

> e.g.\
> Resolves: #123\
> See also: #456, #789

> fix(orders): correct minor typos in code\
> See the issue for details on typos fixed.\
> Reviewed-by: @John Doe\
> Refs #133
---
## GOOD COMMIT MESSAGE
Good commit messages serve at least three important purposes:

* To speed up the reviewing process.
* To help us write a good release note.
* To help the future maintainers, say five years into the future, to find out why a particular change was made to the code or why a specific feature was added.

Information in commit messages:

* Describe why a change is being made.
* How does it address the issue?
* What effects does the patch have?
* Do not assume the reviewer understands what the original problem was.
* Do not assume the code is self-evident/self-documenting.
* Read the commit message to see if it hints at improved code structure.
* The first commit line is the most important.
* Describe any limitations of the current code.
* Do not include patch set-specific comments.
---

