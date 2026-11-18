**AI Conversation Permalink:** Check other file in folder. File should be titled `AI chat log.md` . Do note that the earlier part of my conversation didn't get captured. So it's just the ending portion. 

In terms of context, my research topic began from a minor point in COMP 211 Lecture 31. While in class, we compiled our `printf` vs `write` time comparison code using `gcc -O0` to intentionally prevent compiler optimizations. Obviously, I needed to find out what would happen when the optimizations were enabled. The first thing I did was go to NotebookLM, an AI platform by Google. I started voice mode, and chatted with the LLM for about 15 minutes trying to understand all I could about my topic. After noticing that COMP 211 lecture notes didn't contain any information on the decision policies used by GCC, I made NotebookLM generate a hand-off prompt for a research model and then fed the long answer to my notebook asking it to go over each of the mechanisms in detail until I can clearly describe them.

  

There's three prompts from my conversation that I think illustrates the process above well:

  

> "Can you define loop unrolling? Does it just mean taking a loop body and pasting it multiple times in assembly? Or is there some nuance to the loop unrolling, how many unrolls it does, etc.?"
> 
>   

> "full loop just like um add one to the same variable 500 times does it actually uh output 500 add one assembly calls or can uh GCC ever output just one line of assembly code that says hey let's just add 500 to this number instead of 1 500 times."
> 
>   

> "Can you read through that and just see what the AI reported and then summarize it for me so that I can actually understand what it said. Cuz it's really long." (followed by: "can you explain each and every one of those things in more detail? Let's start with the first one you mentioned.")
> 
>   

Instead of blindly trusting the first high-level summary, I kept chatting and continued to push for concrete mechanics. Most importantly, I did not limit my analysis to passive reading. To test my hypotheses, I made three small C programs (01_loop_collapse.c, 02_loop_unroll.c, and 03_inline_and_fusion.c), compiled them from -O0 through -O3 optimizations, benchmarked them using a time module, and examined their -S assembly by myself. Funnily enough, running actual experiments helped me overcome a wrong assumption. I thought that -O3 optimization does not just unroll my array summation loop. However, GCC optimizes the assembly to reorder the loops, vectorize them using some assembly paddd instructions to sum up four integers in parallel, partially unrolls the pass loop, while fully eliminating the unused 150 million loop in Experiment 01. I unfortunately did have to learn some assembly to understand anything. I never want to do it again.

  
Honestly, if I were doing this all over again, I’d take my time and assess my comprehension during the discussion rather than just taking in one explanation after another. Early on in my discussion with NotebookLM, I was asking questions like "Explain this to me" followed by "Explain it to me in more depth". I should have been asking questions more, and that's what I unintentionally shifted towards near the end. After reviewing my prompts, I found that when I was really interested in something, I was able to ask good follow-up questions. Another improvement for future work is to come up with concise prompts with only one question rather than two or three of them at once.