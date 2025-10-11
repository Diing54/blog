+++
date = '2025-10-11T18:06:19+03:00'
draft = false
title = 'Under the Hood of a Gcc Compiler'
tags = ["C"]
+++
Today I learnt something worth publishing here. As developers we write code day by day and it is executed by our machines. But how does our computers understand this code and execute it ?

I am going to walk through the four core changes of a GCC compiler to transform a simple C program into a state that a machine can understand and execute.

I created a simple file `main.c` below:

```c

#include <stdio.h>

int main() {
    int a = 10;
    int b = 5;
    int result = a + b;
    printf("The result is: %d\n", result);
    return 0;
}
```

### Step 1: Invoking the Preprocessor

This is the first stage. The preprocessor finds this line, `#include <stdio.h>`, in order to extract the stdio.h header file and paste its entire contents into our source code `main.c`

- We run the command `gcc -E main.c -o main.i`
- The `-E` flag tells the GCC to stop after preprocessing
- `-o main.i` specifies the output file name. The `.i` extension is the standard for preprocessed C files

### Step 2: Compile to Assembly Code

We take the preprocessed file and compile it to assembly language, a low-level, but still human-readable.

- We run the command `gcc -S main.i -o main.s`
- The `-S` flag tells the compiler/GCC to stop after compiling to assembly
- The output is `main.s` with assembly code inside

### Step 3: Assemble to Object Code

The assembler's job is to convert the human-readable assembly code into pure machine code (binary)

- We run the command `gcc -c main.s -o main.o`
- The `-c` flag tells the compiler to stop after the assembly stage
- The output is the object file `main.o` which is not yet executable

### Step 4: Link to Create an Executable File

Our object file `main.o` contains the machine code for our main function but it doesn't contain the code for the `printf` function. The linker's job is to find the `printf` code in the C standard library and combine it with our object file to create a runnable program

- We run the command `gcc main.o -o my_program`
- The final executable file `my_program` is created

In the terminal, we can now run our program

`./my_program`

The output is:

`The result is: 15`





### References


