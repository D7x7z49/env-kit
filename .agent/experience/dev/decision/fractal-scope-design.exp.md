<!-- @path[.agent/experience/dev/decision/fractal-scope-design.exp.md] -->
<!-- NOTE: preserve bounded local reasoning across scales -->

STEP.
- represent a complex system as nested scopes with stable boundaries
- give each scope a small contract for purpose, owned state, inputs, outputs, invariants, and failure boundary
- repeat the contract shape at each scale so a known local pattern stays useful in a new scope
- keep each scope understandable from its own contract, its parent contract, and a small explicit neighborhood
- use stable names, order, and layout so structure provides a cheap address and global index
- keep implementation details inside their owning scope and expose only the boundary a neighbor needs
- make a cross-scope dependency explicit, directed, and few
- let local rules and local state produce larger behavior through composition, not global coordination
- inspect the structure first, then load the active scope and only the details the task needs
- change and validate the active scope locally, then check its boundary effects
- preserve the same navigation, contract, and validation pattern as the system grows

NOTE.
- this principle combines boundary-based decomposition, self-similar organization, and bounded local interaction
- use the principle when a reader or an agent works with limited active context
- treat structure as a compression of location, ownership, order, and inheritance
- distinguish self-similarity from fragmentation, because a repeated layout alone is not a useful contract
- do not force a recursive shape onto a domain with no repeated local structure
- treat hidden state, arbitrary ancestor access, and an untracked exception as a break in locality
- keep the active rule set small, and do not claim that total complexity or total work becomes constant
- prefer a stable pattern that supports discovery and safe local change over a clever one that saves local code
- keep this a design lens, not a requirement for every system

---
