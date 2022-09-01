# Holon

A graph sculpting library.

A library for building creative, modelling applications where domain models are
expressed the best as graphs and where the graph is expected to be mutated,
mostly by the user.

Overview of features:

- A directed labelled multi graph with nodes and edges, where both nodes and 
  edges can have multiple labels associated with them.
- Simple predicates for nodes and edges (links)
- Constraint checker, uncoupled
- Special node/link structures for representing groups and proxies
- Graph import/export interfaces

## When the Library is Suitable and when it is not?

The library tries to provide functionality where the whole model can be
represented by a graph with the "Everything is a Graph" perspective.

Suitable applications:

- applications where links need to be first class citizens, not hidden in
  structures of model entities
- applications where ad-hoc relationships between virtually any entity in
  the modelled world might exist
- network modelling
- causal map design
- circuit design

Not suitable applications:

- graph/network analysis – use other tools which focus on efficiency of graph
  representation and traversal with richer query functionality
- problems with very little potential ad-hoc relationships - better
  representable by a relational data model
- problems where links do not have to be first class citizens – use
  object oriented programming instead with object references as member
  variables

### What is it not?

This library is not a graph database, despite resembling some of the elements of
it.

## Features

### Constraint Checker

Constraints and constraints checker is a functionality to define how the graph
structures are expected to be shaped. It is decoupled from the graph structure
so user can create different levels/layers of constraint checks and apply
them when necessary. For example more permissive checker can be used for
a graphical user interface to give feedback about graph design. More
strict checker might be used for conversion of the graph to an actionable
form (from a model to a simulation, for example).

Example:

```swift
let constraints = [
    NodeConstraint(
        name: "proxy_single_subject",
        description: """
                     A proxy must have exactly one subject.
                     """,
        match: LabelPredicate(all: Node.ProxyLabel),
        requirement: UniqueNeighbourRequirement(Node.SubjectSelector,
                                                required: true)
    ),

    LinkConstraint(
        name: "subject_link_origin_is_proxy",
        description: """
                     Origin of the proxy-subject link must be a proxy.
                     """,
        match: LabelPredicate(all: Link.SubjectLabel),
        requirement: LinkLabelsRequirement(
            origin: LabelPredicate(all: Node.ProxyLabel),
            target: nil,
            link: nil
        )
    )
]

let checker = ConstraintChecker(constraints)
let graph = Graph()

// Populate the graph...

let violations = checker.check(graph: graph)

// Process the violations ...
```

### Proxies and Indirection

Proxies and Indirection is an additive, optional functionality for allowing
the modeller to define concepts such as ports, symbolic links, virtual proxies.

Proxy is a type of a node that has another node associated with it – a subject
node. An indirect link is a type of a link where either origin or a target or
both can refer to a proxy.

Using an indirection rewriter the indirection can be rewritten into direct
links.

### Holons

Holons are a special function nodes that represent a hierarchical organisation
of the graph. Typical usage of holons is for grouping objects and managing
group boundaries. Together with proxies the modeller can manage which nodes
can and which can not be connected with nodes from other holons.

Proxies, indirection and holons are represented purely by graph structures. When
exported, they are preserved. When imported, the modeller can check their
validity using a constraint checker with built-in constraint checks.


## Design Principles

Design principle:

- Functionality focuses on creation, synthesis and mutability of a network
  structure. Analytical and query features are low priority.
- Modelling comfort and ease of problem-domain mapping to a graph has
  priority over performance and memory efficiency.
- If a feature can be implemented within the graph, it should be. Optimised
  version might follow, however the interface should be designed in a way, that
  it can always be implemented using just graph components.

Restrictions:

- No core functionality or structure can be added if it can be expressed by
  existing functionality.
- Optimisation – either spatial or temporal – is not a reason to add or change
  anything.


## Development

This toolkit itself is an experiment, a toy, an idea playground and a space
to discover itself.

There is a lot of `#TODO:` and `#FIXME:` markers all over the code. They usually
mark technical debt that I had no time to work on at the moment but was aware
of what needs to be done.


# Disclaimer

The library is experimental.

The code might contain:

- technical debt (usually marked as `FIXME`)
- historical remnants - ways of doing things that seemed to be appropriate
  at the time of the implementation, but were not aligned with the newest
  understanding of the project


# Authors

- Stefan Urbanek, stefan.urbanek@gmail.com
