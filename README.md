# Advent of Code 2023 with Zig
-------------

## Introduction
This repository is dedicated to the personal journey of learning the [Zig programming language](https://ziglang.org) through participation in the [Advent of Code 2023](https://adventofcode.com/2023/) event. Zig is a modern system programming language that prioritizes safety, simplicity, and optimal performance.

## Objectives
- **Exploring Zig**: Familiarize myself with Zig's syntax, features, and its standard library.
- **Data Structures & Algorithms**: Apply and improve my understanding of data structures and algorithms by solving various challenges.
- **Daily Problem Solving**: Engage with the programming community by tackling daily puzzles released during the Advent of Code event.

## Personal Rules
In order to deepen my understanding of computer architecture, memory management, and low-level programming techniques, I will adhere to the following rules throughout the Advent of Code 2023 event:

- **Psychology**: Avoid the mindset of competition. There is no deadline for completion, and I should not rush. This will help maintain focus on learning rather than just solving.
- **Memory Efficiency**: Strive to minimize memory usage for each puzzle. Optimize data structures and algorithms to be as memory-efficient as possible, avoiding unnecessary memory allocation.
- **Standard Library Only**: Limit myself to using only Zig's `std` library. No third-party libraries, string processing libraries, or regular expressions are allowed.
- **Avoid Brute-Force**: Refrain from employing brute-force methods to solve problems. Instead, look for efficient and elegant solutions.
- **Self-Implemented Data Structures & Algorithms** (Optional): Aim to self-implement data structures and algorithms, even basic ones like stacks, queues, hash tables, etc., to reinforce my understanding of these concepts.

## Progress Tracking
Below is the progress tracker for each day of the Advent of Code 2023 event. Each day will be marked as completed once the puzzle is successfully solved.

| Solved | Day | Problem Name | Completion Date | Solved | Day | Problem Name | Completion Date |
|:------:|:---:|--------------|-----------------|:------:|:---:|--------------|-----------------|
|  [X]   | 01  | Trebuchet?!  |      2023-20-17 |  [ ]   | 17  |              |                 |
|  [ ]   | 02  |              |                 |  [ ]   | 18  |              |                 |
|  [ ]   | 03  |              |                 |  [ ]   | 19  |              |                 |
|  [ ]   | 04  |              |                 |  [ ]   | 20  |              |                 |
|  [ ]   | 05  |              |                 |  [ ]   | 21  |              |                 |
|  [ ]   | 06  |              |                 |  [ ]   | 22  |              |                 |
|  [ ]   | 07  |              |                 |  [ ]   | 23  |              |                 |
|  [ ]   | 08  |              |                 |  [ ]   | 24  |              |                 |
|  [ ]   | 09  |              |                 |  [ ]   | 25  |              |                 |
|  [ ]   | 10  |              |                 |  [ ]   | 26  |              |                 |
|  [ ]   | 11  |              |                 |  [ ]   | 27  |              |                 |
|  [ ]   | 12  |              |                 |  [ ]   | 28  |              |                 |
|  [ ]   | 13  |              |                 |  [ ]   | 29  |              |                 |
|  [ ]   | 14  |              |                 |  [ ]   | 30  |              |                 |
|  [ ]   | 15  |              |                 |  [ ]   | 31  |              |                 |
|  [ ]   | 16  |              |                 |

## Comments
**Day 01**
- While trying to optimize memory usage in **Day 01** problem, I figured out that the ~~`FixedBufferAllocator` \*did not\* reuse freed memory~~. Mentioned in [issues#3049](https://github.com/ziglang/zig/issues/3049). That's why I have to expand the memory limit to beable to run on the full data.
- It's turn out to be that the `FixedBufferAllocator` \*did\* reuse freed memory, but one has to free the memory in the order in which it was allocated from last to first (like a stack). Orelse, the allocator will continue to allocate new memory after the last unfree'd memory. // TODO: Update `LinkedList.remove()`` to always remove & free memory from the last element.



_Stay tuned for daily updates and solutions._
