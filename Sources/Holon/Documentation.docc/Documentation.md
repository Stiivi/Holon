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

### Core

- ``Graph``
- ``GraphProtocol``
- ``MutableGraphProtocol``
- ``Node``
- ``Link``
- ``Object``
- ``Path``
- ``LinkSelector``
- ``KeyedValues``
- ``Label``
- ``LabelSet``
- ``LinkDirection``
- ``OID``


### Proxies and Indirection

- ``IndirectionRewriter``
- ``IndirectionConstraints``


### Holons

- ``HolonProtocol``
- ``HolonConstraints``


### Predicates

- ``Predicate``
- ``CompoundPredicate``
- ``NegationPredicate``

- ``LabelPredicate``

- ``NodePredicate``
- ``AnyNodePredicate``

- ``LinkPredicate``
- ``LinkObjectPredicate``

- ``LogicalConnective``

### Constraints and Constraints Checker

- ``ConstraintChecker``
- ``ConstraintViolation``
- ``Constraint``
- ``ObjectConstraintRequirement``
- ``NodeConstraint``
- ``NodeConstraintRequirement``
- ``LinkConstraint``
- ``LinkConstraintRequirement``
- ``LinkLabelsRequirement``
- ``UniqueNeighbourRequirement``
- ``UniqueProperty``
- ``AcceptAll``
- ``RejectAll``

### Import and Export Interfaces

- ``DotExporter``
- ``DotFormatter``
- ``DotStyle``
- ``DotLinkStyle``
- ``DotNodeStyle``
- ``DotGraphType``


### Utility

- ``UniqueIDGenerator``
- ``SequentialIDGenerator``


