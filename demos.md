# Demo Notes for a PPL Lecture

Demos start with the programs in `code/`.

1. `flip.wppl`.
   Run multiple times to show that the outcome is nondeterministic.

2. `enumerate.wppl`.
   Run multiple times to show that the distribution result is deterministic.
   Emphasize that the execution is doing something strange to follow all the different paths through the program.

3. `model.wppl`.
   This is enough to write our model in "forward mode," to simulate the reading behavior of students.
   It doesn't do predictions yet.
   But we get to use functions and variable names and stuff!

4. `roll4.wppl`.
   Just add this condition to `enumerate.wppl`:

       // Only keep executions where at least one die is a 4.
       if (!(die1 === 4 || die2 === 4)) {
         factor(-Infinity);
       }

5. `roll10.wppl`.
   Take that out and instead put this condition into the enumerate example:

      var out = die1 + die2;
      if (out !== 10) {
        factor(-Infinity);
      }

   Then change the sum on the `return` line to produce a string:

      return die1 + " + " + die2;

   This is the magic we need to condition on *observations* and show the distribution of possible *input conditions*.

6. `recommend.wppl`.
   Show recommendations for my class attendance.
   Try changing the Booleans to model people that go to only 4110 or only 4780 to get different recommendations.

7. `recommend-rs.wppl`.
   Show `ParticleFilter` call.
   Run multiple times to show it's nondeterministic again.
   This helps scale to much larger programs, where exhaustively enumerating all the paths is intractable.
   There are lots of other fancy sampling algorithms that I won't go into here, but you can explore stuff like Markov chain Monte Carlo simulations.
