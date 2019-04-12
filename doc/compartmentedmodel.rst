:class:`CompartmentedModel`: Compartmented models of disease
============================================================

.. currentmodule:: epydemic

.. autoclass:: CompartmentedModel
   :show-inheritance:

Compartmented models are designed so that their specification is
independent of the :term:`process dynamics` used to simulate them:
they can be run in :term:`discrete time` using :term:`synchronous dynamics`,
or in :term:`continuous time` using :term:`stochastic dynamics`.

:class:`CompartmentedModel` is an abstract class that must be
sub-classed to define actual disease models. `epydemic` provides
implementations of the two "reference" compartmented models,
:class:`SIR` and :class:`SIS`, as well as several variants of them:
:ref:`Hethcote <Het00>` provides a survey of a huge range of others.


Attributes
----------

.. autoattribute:: CompartmentedModel.COMPARTMENT

.. autoattribute:: CompartmentedModel.OCCUPIED

.. autoattribute:: CompartmentedModel.DEFAULT_COMPARTMENT


Model setup
-----------

Immediately before being run, the model is set up by placing all the
nodes into compartments. All edges are also marked as unoccupied.

.. automethod:: CompartmentedModel.reset

.. automethod:: CompartmentedModel.build

.. automethod:: CompartmentedModel.setUp

.. automethod:: CompartmentedModel.initialCompartmentDistribution

.. automethod:: CompartmentedModel.initialCompartments


Building the model
------------------

Building a model (within :meth:`CompartmentedModelbuild`) means specifying
the various compartments, loci, and events, and their associated probabilities.

.. automethod:: CompartmentedModel.addCompartment

.. automethod:: CompartmentedModel.trackNodesInCompartment

.. automethod:: CompartmentedModel.trackEdgesBetweenCompartments


Evolving the network
--------------------

Events in compartmented models need an interafce to change the compartment of nodes
and to mark edges used in transmitting the epidemic.

.. automethod:: CompartmentedModel.setCompartment

.. automethod:: CompartmentedModel.changeCompartment

.. automethod:: CompartmentedModel.markOccupied

The network access interface of :class:`Process` is extended with methods that
understand the mappings between nodes, edges, and compartments.

.. automethod:: CompartmentedModel.addNode

.. automethod:: CompartmentedModel.removeNode

.. automethod:: CompartmentedModel.addEdge

.. automethod:: CompartmentedModel.removeEdge



