title: Probabilistic Programming

[TITLE]

These are notes from an overview lecture at [the November, 2015 Dagstuhl seminar on approximate and probabilistic computing][dagstuhl].
The lecture is an introduction to [probabilistic programming][ppl] for people from across the broad spectrum of backgrounds at the workshop, so it starts with the absolute basics.
In particular, I find that most introductions to PPL are written for and by machine-learning and statistics experts.
(Here's [an exception][ple-ppl] from Michael Hicks at [the *Programming Languages Enthusiast* blog][ple].)
I'm a programming-languages person, so these notes start from the opposite perspective from most tutorials.

[ple]: http://www.pl-enthusiast.net/
[dagstuhl]: http://www.dagstuhl.de/en/program/calendar/semhp/?semnr=15491
[ple-ppl]: http://www.pl-enthusiast.net/2014/09/08/probabilistic-programming/
[ppl]: http://probabilistic-programming.org/wiki/Home

What and Why
============

Probabilistic Programming is Not
--------------------------------

Let's start by dispensing with misconceptions. Probabilistic programming is *not* just about writing software that can call `rand(3)` as part of the work it's intended to do (like a cryptographic key generator, or an ASLR implementation in an OS kernel, or even a simulated-annealing optimizer for circuit designs).

It's best not to think of "writing software" at all. By way of analogy, the traditional languages C++, Haskell, and Python are obviously very different in philosophy, but you can imagine (if forced) using any of them to write, say, a cataloging system for your cat pictures or a great new alternative to LaTeX. One might be better for a given domain than the other, but they're all workable. Not so with probabilistic programming languages (PPL). It's more like Prolog: sure, it's a programming language, but it's not for writing full-fledged software.

Probabilistic Programming Is
----------------------------

Probabilistic programming is *a tool for statistical modeling*. The idea is to borrow lessons from the world of programming languages and apply them to the problems of designing and using statistical models.
Experts construct statistical models already, by hand, in mathematical notation on paper, but it's an expert-only process that's hard to support with mechanical reasoning.
The key insight in PP is that statistical modeling can, when you do it enough, start to feel a lot like programming.
If we make the leap and actually use a real language for our modeling, many new tools become feasible.
We can start to automate the tasks that used to justify writing a paper for each instance.

Here's a second definition: a probabilistic programming language is an ordinary programming language with `rand` and a great big pile of related tools that help you understand the program's statistical behavior.

Both of these definitions are accurate. They just emphasize different angles on the same core idea. Which one makes sense to you will depend on what you want to use PP for. But don't get distracted by the fact that PPL programs look a lot like ordinary software implementations, where the goal is to *run* the program and get some kind of output. The goal in PP is analysis, not execution.

### An Example: Paper Recommendations

~ Figure { caption: "A paper-recommendation problem. The light circles are observed; the heavy circles are the outputs we want." }
![ex-problem]

[ex-problem]: fig/ex-problem.[pdf,svg]
~

As a running example, let's imagine that we're building a system to recommend papers to researchers based on the conferences they attend.
To keep things simple, let's say there are only two research topics in the world: programming languages and statistics.
Every paper is either a PL paper, a statistics paper, or both.
And there are three venues in the world: PLDI, NIPS, and this Dagstuhl seminar.

It's pretty easy to imagine that machine learning should work for this problem: the mixture of areas revealed by your conference schedule should say something about the papers you want to read.
The problem is that the exact relationship can be hard to reason about directly.
Clearly attending NIPS means you're more likely to be interested in statistics, but exactly *how much* more likely?
What if you just went to NIPS because it was in your hometown and you were curious?
What do we do about people who *only* attend this Dagstuhl and neither conference---do we just assume they're 50/50 PL/stats people?

#### Modeling the Problem

~ Figure { caption: "A model for how interest influences conference attendance and paper relevance. Dashed circles are latent variables: neither inputs nor outputs." }
![ex-model-full]

[ex-model-full]: fig/ex-model-full.[pdf,svg]
~

The machine-learning way of approaching this problem is to *model* the situation using *random variables*, some of which are *latent*.
The key insight is that the arrows are weird in our original diagram: they don't really represent causality!
It's not that attending PLDI makes you more interested in a given paper; there's some other factor that probabilistically causes both events.
These are the *latent* random variables in a model for explaining the situation.
Allowing yourself latent variables makes it much easier to reason directly about the problem.

Here's a model that introduces a couple of latent variables for each person's interest in statistics and programming languages.
We'll get more specific about the model, but now the arrows at least make sense: they mean that one variable *influences* another in some way.
Since we all know that you don't go to every conference you're interested in, we include a third hidden factor: how *busy* you are, which makes you less likely to go to *any* conference.

This diagram of depicts a *Bayesian network*, where each vertex is a random variable and each edge is a statistical dependence.
Variables that don't have edges between them are statistically independent. (That is, knowing something about one of the variables tells you nothing about the outcome of the other.)

~ Figure { caption: "The rest of the model: how interest influences paper relevance." }
![ex-model-out]

[ex-model-out]: fig/ex-model-out.[pdf,svg]
~

The idea isn't that we'll ask people what their interest levels and business are: we'll try to *infer* it from what we can observe. And then we can use this inferred information to do what we actually want: to guess paper relevance.

### A Model for Humans

So far, we've draw pictures of the dependencies in our model, but we need to get specific about what we mean.
Here's how it normally goes: you write down a bunch of math that relates the random variables.

$ \text{Pr} [ A_\text{NIPS} | I_\text{stats} \wedge B ] = 0.3 $ \
$ \text{Pr} [ A_\text{NIPS} | I_\text{stats} \wedge \neg B ] = 0.8 $ \
$ \text{Pr} [ A_\text{NIPS} | \neg I_\text{stats} ] = 0.1 $ \
$ ... $ \
$ \text{Pr} [ A_\text{Dagstuhl} | I_\text{stats} \wedge I_\text{PL} ] = 0.3 $ \
$ \text{Pr} [ A_\text{Dagstuhl} | I_\text{stats} \wedge I_\text{PL} \wedge \neg B ] = 0.8 $ \
$ \text{Pr} [ A_\text{Dagstuhl} | \neg (I_\text{stats} \vee I_\text{PL}) ] = 0.1 $ \
$ ... $ \
$ R_1 \sim I_\text{PL} \wedge I_\text{stats} $ \
$ R_2 \sim I_\text{PL} $ \
$ R_3 \sim I_\text{stats} $

That's a lot of math for such a simplistic model! And it's not even the hard part.
The hard---and useful---bit is *statistical inference*, where we guess the latent variables based on our observations.
Statistical inference is a cornerstone of machine-learning research, and it's not easy.
Traditionally, experts design bespoke inference algorithms for each new model they devise *by hand*.

I hope you can already see the *drudgery* that this task has in common with writing assembly. There are no abstractions, no reuse, no descriptive variable names, no comments, no debugger, no type systems---and yet we're doing something that is starting to feel like programming. Look at the equations for the conference attendance, for example: I got tired of writing out all that math because its so repetative. This is clearly a job for an old-fashioned programming language abstraction: a function. The goal of PPLs is to bring the old and powerful magic of programming languages, which you already know and love, to the world of statistics.

### Let's Make This a Language

The idea behind probabilistic programming is to codify most of this modeling work in a language that computers can understand.
Then, instead of painstakingly devising a new inference algorithm for every new model, we can seek to make that the job of the compiler and tools.


Basic Concepts
==============

To introduce the basic concepts of a probabilistic programming language, I'll use a project called [webppl][], which is a PPL embedded in JavaScript.
You can read more about this language in [*The Design and Implementation of Probabilistic Programming Languages*][dippl], an in-progress book by [Noah Goodman][] and [Andreas Stuhlmüller][] from Stanford.

[Noah Goodman]: http://cocolab.stanford.edu/ndg.html
[Andreas Stuhlmüller]: http://stuhlmueller.org/
[webppl]: http://webppl.org/
[dippl]: http://dippl.org

## Random Primitives

The first piece of a PPL is just an ordinary programming language with primitives for drawing random numbers.
This part looks very much like any old imperative language with a `rand` call.
Here's an incredibly boring webppl program:

    var b = flip(0.5);
    b ? "yes" : "no"

This boring program just uses the outcome of a fair coin toss to return one string or another.
It works exactly like an ordinary program with access to a `flip` function for producing random Booleans.
Functions like `flip` are sometimes called *elementary random primitives*, and they're the source of all randomnes in these programs.

Things get slightly more interesting when we realize that webppl can represent entire distributions, not just individual values.
The webppl language has an `Enumerate` operation, which prints out all the probabilities in a distribution defined by a function:

    var roll = function () {
      var die1 = randomInteger(7) + 1;
      var die2 = randomInteger(7) + 1;
      return die1 + die2;
    }

    Enumerate(roll)

You get a printout with all the possible die values between 2 and 14 and their associated probabilities. You can also run the example in [webppl's in-browser interface][webppl] to get a pretty graph.

This may not look all that surprising, since you could imagine writing `Enumerate` in your favorite language by just running the function over and over. But in fact, `Enumerate` is doing something a bit more powerful. It's just sampling executions to get an *approximation* of the distribution; it's actually enumerating *every possible execution* of the function to get an *exact* distribution.
This begins to reveal the point of a probabilistic programming language: the tools that *analyze* PPL programs are the important part, not actually executing the programs directly.

## Our Example Model in webppl

This is enough to code up the math for our paper-recommender model. We can write functions to encode the relevance piece and the conference attendance piece, and we can test it out by randomly generating "researcher profiles."

    // Conference attendance.
    var attendance = function(i_pl, i_stats, busy) {
      var attendance = function (interest, busy) {
        if (interest) {
          return busy ? flip(0.3) : flip(0.8);
        } else {
          return flip(0.1);
        }
      }
      var a_pldi = attendance(i_pl, busy);
      var a_nips = attendance(i_stats, busy);
      var a_dagstuhl = attendance(i_pl && i_stats, busy);

      return {PLDI: a_pldi, NIPS: a_nips, Dagstuhl: a_dagstuhl};
    }

    // Relevance of our three papers.
    var relevance = function(i_pl, i_stats) {
      var rel1 = i_pl && i_stats;
      var rel2 = i_pl;
      var rel3 = i_stats;

      return {paper1: rel1, paper2: rel2, paper3: rel3};
    }

    // A combined model.
    var model = function() {
      // Some even random priors for our "researcher profile."
      var i_pl = flip(0.5);
      var i_stats = flip(0.5);
      var busy = flip(0.5);

      return [relevance(i_pl, i_stats), attendance(i_pl, i_stats, busy)];
    }

    Enumerate(model)

Running this will show the distribution over all the observed data. This isn't terribly useful, but it is interesting. We can see, for example, that if we know *nothing else* about a researcher, our model says they're quite likely to go to none of the conferences and to be interested in none of the papers. Fine.

## Conditioning

The next important piece of a PPL is a *conditioning* construct.
Conditioning lets you determine how much to weight to give to a given execution in a program.
Crucially, you can choose the weight of an execution partway through the run---after doing some of the computation.
You can even mark an execution as *completely irrelevant*, effectively filtering the executions to a subset.

This conditioning operation is particularly useful for encoding *observations*.
If you know something about the outcome of a process, you can use conditioning to communicate that the observation must be true (or is likely to be true).
Let's return to our dice example for a contrived example.
Say that we saw the first die, and it's a 4.
We can condition on this information to give us the distribution on total values given that one of the dice is a 4:

    var roll = function () {
      var die1 = randomInteger(7) + 1;
      var die2 = randomInteger(7) + 1;

      // Only keep executions where at least one die is a 4.
      if (!(die1 === 4 || die2 === 4)) {
        factor(-Infinity);
      }

      return die1 + die2;
    }

    Enumerate(roll)

Unsurprisingly, the distribution is flat except for the outcome 8, which is less likely.

What if, on the other hand, we don't get to see either of the dice, but someone told us that the total on the dice was 10. What does this tell us about the values of the dice themselves?
We can encode this observation by conditioning on the outcome of the roll.

    var roll_condition = function () {
      var die1 = randomInteger(7) + 1;
      var die2 = randomInteger(7) + 1;

      // Discard any executions that don't sum to 10.
      var out = die1 + die2;
      if (out !== 10) {
        factor(-Infinity);
      }

      // Return the values on the dice.
      return [die1, die2];
    }

    Enumerate(roll_condition)

The results probably don't surprise you, but we can use the same principle with our recommender.

## Actually Recommending Papers

Let's use the same philosophy now to actually produce recommendations. It's simple: we just need to condition on the conference attendance of the person we're interested in.
Here's an example with my conference attendance this year.

    var recc = function() {
      var i_pl = flip(0.5);
      var i_stats = flip(0.5);
      var busy = flip(0.5);

      // Require my conference attendance.
      var att = attendance(i_pl, i_stats, busy);
      require(att.Dagstuhl && att.PLDI && !att.NIPS);

      return relevance(i_pl, i_stats);
    }

Calling `Enumerate` on this `recc` function finally gives us something useful: a distribution over paper relevance! It's a little easier to understand if we just look at one paper at a time:

    return relevance(i_pl, i_stats).paper1;

Suddenly, this is pretty nifty! By telling the enumerator which *executions* are relevant to us, it can tell us what it knows about data *under those conditions*. To me, and I think to most programmers, this already feels like a much more natural tool for expressing probabilistic models. Rather than carefully writing down which random variables depend on which others, you use the flow of program execution to build up those dependencies.

The point of this section: Writing generative models feels very comfortable and straightforward, and a programming language is a great way to write down a generative algorithm. We've successfully made our job easy by shifting the burden of doing inference on these simple models to the compiler and tools.

## Inference

That `Enumerate` operation might not look like much, but it's actually an implementation of the central problem that PPLs were meant to solve: *statistical inference*. Especially in the presence of conditioning, inference on a general probabilistic program is a hard problem. Think about how `Enumerate` must work: it needs to know the outcome of a program for *every single valuation* of the program's random primitive draws. It's not hard to see how this grows exponentially. And it's even less clear if you introduce floating-point numbers: if you draw a number between 0.0 and 1.0, that's a *lot* of possible valuations—and it's not representable as a histogram.

`Enumerate` just won't do for nontrivial problems. It's for this reason that efficient inference algorithms for PPLs are a huge focus in the community. Here are a couple of other inference algorithms that don't involve exploring every possible execution of a program.

### Rejection Sampling

The second most obvious inference algorithm uses *sampling*. The idea is to run the program a large number of times, drawing different random values for each random primitive on each execution. Apply the program's conditioning to weight each sample and total them all up. The interaction with weighting makes this strategy *rejection sampling*, so called because you reject some executions when you reach a conditioning statement.

The webppl language has this strategy built in. It's called `ParticleFilter`, and we can run it on our examples from above.

**TK** example

But rejection sampling runs into trouble in the presence of conditioning. Check out this contrived program, which filters out all but a very small number of executions:

**TK** example

#### MCMC

**TK**
record trace
flip a choice
continue executing from there (reusing wherever possible)


Applications
============

To be as starry-eyed as possible, the promise of PP is nothing less than the democratization of machine learning.

In case you're not convinced yet, here are a sampling of popular applications of probabilistic programming.

* [TrueSkill][] is perhaps the most widely cited example, originally laid out in [this ESOP'11 paper][tspaper]. It's the model used by multiplayer Xbox games to find good matchups among players. The idea is to model latent variables for the player's skills and to match people up so that the predicted win probability is close to 50/50.
* The webppl book has a nifty [computer vision demo][vision] that shows how a generative "forward" model can also be used "backward" to solve a complementary problem.
* [Forest][] is a dizzying resource of generative models written in PPLs for domains from cognition and NLP to document retrieval.
* This is not quite an application yet, but [Gamalon][] is a new startup founded by Ben Vigoda of [Lyric Semiconductor][], [Noah Goodman][], and others. It seems to be centered around probabilistic programming.
* Then there's my favorite application: understanding normal programs that deal with probabilities. There is a lot of ordinary software that deals with probabilistic behavior:
    - approximate computing
    - dealing with sensors
    - security/obfuscation

[Forest]: http://forestdb.org/
[vision]: http://dippl.org/examples/vision.html
[TrueSkill]: http://research.microsoft.com/apps/pubs/default.aspx?id=67956
[tspaper]: http://research.microsoft.com/pubs/135344/MSR-TR-2011-18.pdf
[Lyric Semiconductor]: http://www2.technologyreview.com/tr50/lyricsemiconductor/
[Ben Vigoda]: http://computefest.seas.harvard.edu/people/ben-vigoda
[Gamalon]: https://gamalon.com/

Techniques
==========

## Probabilistic Assertions

On the topic of ordinary programs that encounter probabilistic behavior, I worked last year on an analysis tuned specifically for that kind of program. At the risk of self-promotion, I'll describe it here—it's especially relevant for the approximate computing part of the seminar's theme.

The goals are:
- Work on messy programs in a real-world programming language (here, LLVM programs, so think C and C++).
- Make it fast to check statistical properties on the output. Think quality thresholds for approximate programs.
- We don't care about conditioning.

The idea centers around introducing a new, probabilistic correctness construct into a mainstream language. What do all these PPL tools look like if they're recontextualized in the setting of ordinary software? It looks like a *probabilistic assertion*.

## R2

R2 is a probabilistic programming language and implementation from Microsoft.
The tool is [available for download][r2dl].

One particularly nifty component of R2 is the application of classic PL ideas to improve statistical inference. Most prominently, the R2 people use weakest preconditions analysis to improve rejection sampling—that naive randomized inference strategy we talked about before.

The WP  approach addresses the most frustrating aspect of conditioning: the fact that you find out *after* doing a bunch of work that you have to throw it all away. In this passage from earlier:

    var die1 = randomInteger(7) + 1;
    var die2 = randomInteger(7) + 1;

    // Discard any executions that don’t sum to 10.
    var out = die1 + die2;
    require(out === 10);

we condition late in the program, which is inefficient if we use a naive strategy. (Bear with me here and pretend that the addition in the second-to-last line is expensive.) We can improve this program by making the assertion earlier in the program. And, in fact, that is the essence of a WP analysis, which asks, *What must be true at program point A in order to make a different property true at a later point B?* In our example, we can "move up" the condition to fail faster:

    var die1 = randomInteger(7) + 1;
    var die2 = randomInteger(7) + 1;

    require((die1 == 3 && die2 == 7) || ...);
    var out = die1 + die2;

If we're lucky, we can even move the condition all the way back *into* the primitive sampling call—and avoid doing any work at all that will eventually be rejected later.

[r2dl]: http://research.microsoft.com/en-us/downloads/40e37dc8-1337-43e9-88af-03eabf591208/

## Porting PL Ideas to PP

Another little cottage industry in the PP community is porting the ideas we take for granted in ordinary programming languages and porting them to PP. Here are some examples:

* [Static analysis][sriram-pldi13]: proving assertions
* [Termination checking][martengales]
* [Program slicing][slicing]
* [Program synthesis][synthesis]

[synthesis]: http://research.microsoft.com/pubs/244984/paper.pdf
[slicing]: http://research.microsoft.com/pubs/208584/slicing.pdf
[martengales]: https://www.cs.colorado.edu/~srirams/papers/cav2013-martingales.pdf
[sriram-pldi13]: http://research.microsoft.com/en-us/um/people/sumitg/pubs/pldi13-prob.pdf
