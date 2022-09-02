# Proxies and Indirection

<!--@START_MENU_TOKEN@-->Summary<!--@END_MENU_TOKEN@-->

## Overview

The library has a built-in functionality to create indirections through proxies.
Some nodes can be marked as proxies and links to those proxies can be marked
as indirect. Using a graph rewriter the indirect links can be converted
to direct links.

### Proxies

Proxies are nodes that have system label ``Node/ProxyLabel``. Any node can be
a proxy node. Each proxy node represent another node - its real subject.
Therefore each proxy node requires a link between the proxy node and its
subject.

The link between proxy node and its subject has a system label
``Link/SubjectLabel``, the proxy is the origin of the link and subject is the
target of the link.

### Links

Links that are to be interpreted as indirect have endpoints pointing to proxies
and have the endpoints marked as indirect through appropriate label:
``Link/IndirectOriginLabel`` is used to mark that the link's origin is indirect,
``Link/IndirectTargetLabel`` is used to mark that the link's target is indirect.
If an endpoint of a link is a proxy, but the endpoint is not marked as indirect,
it means that the endpoint is the proxy object itself.

The following example depicts an indirection: the `Device A` is logically
connected to the `Device B` through the port, which is a proxy node.

```
              (indirect target)          (subject)
    Device A --------------------→ Port -----------→ Device B
                                  (proxy)
```

After graph rewriting we will get the following graph:

```
               
    Device A -------------------------------------------+
                                                        |
                                         (subject)      ↓
                                   Port -----------→ Device B
                                  (proxy)
```


The following example depicts direct links from the `Box` node to `Port` nodes.
This graph will not be interpreted as having indirect links.

```
                          (subject)
    Box --------→ Port 1 -----------→ Device A
     |            (proxy)
     |                    (subject)
     +----------→ Port 2 -----------→ Device B
                  (proxy)
```

After graph rewriting we will get the same graph.



### Constraints and Graph Consistency

When using proxies, the provided functionality, such as rewriting with the
``IndirectionRewriter`` requires that the graph follows all the rules around
indirection. The rules are described as graph constraints and listed in the
constant list ``IndirectionConstraints``. It is required by the user to
follow and/or validate the constraints before using any functionality related
to indirection. Working with graph violating the constraints is considered
a programming error. The constraints are not enforced immediately while working
with the graph, since building of the graph might be incremental and
intermediate steps might not be valid. 

See ``ConstraintChecker`` for more information about how to validate
constraints.


## Topics


### Functionality

- ``IndirectionRewriter``
- ``IndirectionConstraints``

### System Node and Link Labels

- ``Node/ProxyLabel``
- ``Link/IndirectOriginLabel``
- ``Link/IndirectTargetLabel``
- ``Link/SubjectLabel``
