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




### References
