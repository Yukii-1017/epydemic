.. _model-human-population:

.. currentmodule:: epydemic

Modelling human contact networks
================================

**Problem**: You want to work with a realistic model of a human contact network. What is the appropriate topology?

**Solution**: This is an active area of research, but a common answer is to use the approach given by
:ref:`Newman <New02>`, which is to use a powerlaw network with exponential cut-off.


The theory
----------

A powerlaw network with exponent :math:`\alpha` has a degree distibution given by

.. math::

    p_k \propto k^{-\alpha}

where :math:`p_k` is the probability that a randomly-chosen node in the network will have degree :math:`k`. This
degree distribution has the property that some nodes can have very high degrees with non-zero probability, leading
to very large hubs with high centrality. In a population network this would introduce individuals who were
massively better connected than the others, which is generally considered undesirable: therre are limits to how
many people even the most popular person can actually come into physical contact with.

A powerlaw-with-cutoff network, by contrast, place a limit (denoted :math:`\kappa`) on the "likely" highest degree.
Up to the cutoff the degree distribution behaves like a powerlaw network; above the cutoff, the probability drops
off exponentially quickly, making large hubs highly unlikely. This degree distribution is given by

.. math::

    p_k \propto k^{-\alpha} \, e^{-k / \kappa}

The following plot shows the difference in the probability of encountering nodes of different degrees under
the two distributions.

.. figure:: powerlaw-cutoff.png
    :alt: Powerlaw vs powerlaw with cutoff degree distributions
    :align: center

So the probability of finding, for example, a node of degree 100 is :math:`p_k \approx 0.0001` under the powerlaw
distribution, whereas with a cutoff at :math:`\kappa = 10` the probability drops to :math:`p_k \approx 0.00000001`
-- ten thousand times smaller.

Note that these distributions are expressed as proportionalities, because that exposes the essence of what's going on. To
actually implement the distributions, though, we need to know the constants of proportionality :math:`\frac{1}{C}` that normalise the
distribution so that the area under the curve is one. For the powerlaw with
cutoff this constant is built from a `polylogarithm <https://en.wikipedia.org/wiki/Polylogarithm>`_, :math:`C = Li_\alpha(e^{-1 /\kappa})`, a "special" function that's
fortunately built-into the ``mpmath`` package,
so all we need to do is code-up the distribution function in Python. (The equivalent for the powerlaw distribution is
built from the `Hurwitz zeta function <https://en.wikipedia.org/wiki/Hurwitz_zeta_function>`_, :math:`C = \zeta(\alpha, 1)`.)


The engineering
---------------

We can now simply code-up this mathematics, using parameters for the size :math:`N` of the network
its exponent :math:`\alpha` and cutoff :math:`\kappa` to construct a random network:

.. code-block:: python

    import networkx
    import epydemic
    import math
    import numpy
    from mpmath import polylog as Li   # use standard name

    def makePowerlawWithCutoff( self, alpha, kappa ):
        '''Create a model function for a powerlaw distribution with exponential cutoff.

        :param alpha: the exponent of the distribution
        :param kappa: the degree cutoff
        :returns: a model function'''
        C = Li(alpha, math.exp(-1.0 / kappa))
        def p( k ):
            return (pow((k + 0.0), -alpha) * math.exp(-(k + 0.0) / kappa)) / C
        return p

    def generateFrom( self, N, p, maxdeg = 100 ):
        '''Generate a random graph with degree distribution described
        by a model function.

        :param N: number of numbers to generate
        :param p: model function
        :param maxdeg: maximum node degree we'll consider (defaults to 100)
        :returns: a network with the given degree distribution'''

        # construct degrees according to the distribution given
        # by the model function
        ns = []
        t = 0
        for i in range(N):
            while True:
                k = 1 + int (numpy.random.random() * (maxdeg - 1))
                if numpy.random.random() < p(k):
                    ns = ns + [ k ]
                    t = t + k
                    break

        # if the sequence is odd, choose a random element
        # and increment it by 1 (this doesn't change the
        # distribution significantly, and so is safe)
        if t % 2 != 0:
            i = int(numpy.random.random() * len(ns))
            ns[i] = ns[i] + 1

        # populate the network using the configuration
        # model with the given degree distribution
        g = networkx.configuration_model(ns, create_using = networkx.Graph())
        g = g.subgraph(max(networkx.connected_components(g), key = len)).copy()
        g.remove_edges_from(list(g.selfloop_edges()))
        return g

The ``makePowerlawWithCutoff`` function just transcribes the definition of the distribution from above, taking the
distribution parameters :math:`\alpha` and :math:`\kappa` and returning a model function that, for any
degree :math:`k`, returns the probability :math:`p_k` of encountering a node of that degree.

The actual construction of the network is done in the ``generateFrom`` function using the configuration model, where we
first build a list of :math:`N` node degrees by repeatedly drawing from the powerlaw-with-cutoff distribution. Actually
this function will construct a network with *any* desired degree distribution by defining an appropriate model
function.

You can use this code to create human population models that you then pass to an experiment (an instance of :class:`Dynamics`)
that runs the appropriate network process over the network. You can also embed the code into a class for use in larger-scale
experiments: see :ref:`build-network-in-experiment` for an explanation of this approach.
