# ``Holon``

A graph sculpting library.

## Overview

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

### When the Library is Suitable and when it is not?

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

## Topics

### Graph

Graph is an object that represents a mutable oriented labelled graph structure.
It is composed of nodes and links between the nodes. Graph and
associated structures are the core of the Holon library.

- <doc:GraphCore>


### Proxies and Indirection

- <doc:ProxiesAndIndirection>


### Holons

- <doc:HolonHierarchy>


### Predicates

- <doc:Predicates>

### Constraints and Constraints Checker

- <doc:Constraints>


### Import and Export Interfaces

- <doc:ImportExport>


### Utility

- ``UniqueIDGenerator``
- ``SequentialIDGenerator``


