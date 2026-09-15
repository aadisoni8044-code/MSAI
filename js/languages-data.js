/**
 * DevSyntax Languages Data Registry
 * Contains structured metadata and interactive learning topics for 16 programming languages.
 */

const LANGUAGES_DATA = {
    python: {
        id: "python",
        name: "Python",
        category: "backend",
        tagline: "Easy to learn • Beginner Friendly",
        badge: "Popular",
        color: "#3776AB",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2c-5.5 0-5 2.4-5 2.4V7h5v1H5.4S2 7.6 2 12s2.4 4.8 2.4 4.8H6V15s-.2-2.8 2.8-2.8h4.4s2.8 0 2.8-2.8V4.8S17.5 2 12 2zm-2.2 2a1.1 1.1 0 1 1 0 2.2 1.1 1.1 0 0 1 0-2.2zM12 22c5.5 0 5-2.4 5-2.4V17h-5v-1h6.6s3.4.4 3.4-4-2.4-4.8-2.4-4.8H18V9s.2 2.8-2.8 2.8h-4.4s-2.8 0-2.8 2.8v4.6s-1.5 2.8 4 2.8zm2.2-2a1.1 1.1 0 1 1 0-2.2 1.1 1.1 0 0 1 0 2.2z"/></svg>`,
        description: "High-level programming language famous for readable syntax, data science, AI, and web backend development.",
        categories: [
            {
                id: "basics",
                title: "Basics & I/O",
                topics: [
                    {
                        id: "py-print",
                        name: "print()",
                        type: "function",
                        shortDesc: "Displays output to the console terminal",
                        difficulty: "Easy",
                        whatIsIt: "The print() function sends textual or numerical output to the standard output device (your terminal screen). It is usually the first command taught to programming beginners.",
                        syntax: "print(value1, value2, ..., sep=' ', end='\\n')",
                        codeExample: `# Demonstration of Python print()
name = "DevSyntax Learner"
version = 3.12

print("Welcome to", name)
print(f"Python Version: {version}")
print("Line 1", "Line 2", sep=" | ")`,
                        expectedOutput: `Welcome to DevSyntax Learner
Python Version: 3.12
Line 1 | Line 2`,
                        howItWorks: [
                            "`print()` converts all passed arguments into strings.",
                            "Arguments are joined by the `sep` string (defaults to a space ' ').",
                            "Appends the `end` string at the end of the output (defaults to newline `\\n`).",
                            "Flushes the string buffer to the display terminal."
                        ],
                        parameters: [
                            { name: "*objects", type: "Any", desc: "One or more values to display." },
                            { name: "sep", type: "str", desc: "String inserted between objects (default ' ')." },
                            { name: "end", type: "str", desc: "String appended at the end (default '\\n')." }
                        ],
                        returnValue: "None",
                        commonMistakes: "Forgetting parentheses in Python 3 (e.g. typing `print \"Hello\"` instead of `print(\"Hello\")`).",
                        realWorldUse: "Logging diagnostic messages, printing formatted reports, and debugging software execution step by step.",
                        relatedTopics: ["py-input", "py-f-strings"]
                    },
                    {
                        id: "py-input",
                        name: "input()",
                        type: "function",
                        shortDesc: "Reads a string line from user console input",
                        difficulty: "Easy",
                        whatIsIt: "The input() function pauses program execution and prompts the user to type text into the terminal console until they press Enter.",
                        syntax: "user_text = input(prompt_message)",
                        codeExample: `# Reading user input
user_name = "Alex" # Simulated input
print(f"Hello, {user_name}! Ready to code Python?")`,
                        expectedOutput: "Hello, Alex! Ready to code Python?",
                        howItWorks: [
                            "Displays the optional prompt message string to the user.",
                            "Waits for keyboard input until newline (Enter key).",
                            "Returns the entered line strictly as a string datatype."
                        ],
                        parameters: [
                            { name: "prompt", type: "str", desc: "Optional message printed before waiting for input." }
                        ],
                        returnValue: "str (The string entered by the user)",
                        commonMistakes: "Expecting a number directly without typecasting (e.g., forgetting `int(input())`).",
                        realWorldUse: "Building interactive command-line interfaces (CLI tools) and collecting input scripts.",
                        relatedTopics: ["py-print", "py-type-conversion"]
                    }
                ]
            },
            {
                id: "functions",
                title: "Functions & Keywords",
                topics: [
                    {
                        id: "py-def",
                        name: "def",
                        type: "keyword",
                        shortDesc: "Defines a reusable function block",
                        difficulty: "Easy",
                        whatIsIt: "The `def` keyword is used to create and declare a user-defined function in Python. Functions allow you to group reusable blocks of code together.",
                        syntax: "def function_name(param1, param2):\n    # function body\n    return result",
                        codeExample: `# Defining and calling a function
def calculate_area(width, height):
    """Calculates the area of a rectangle."""
    return width * height

rect_area = calculate_area(5, 10)
print(f"Rectangle Area: {rect_area}")`,
                        expectedOutput: "Rectangle Area: 50",
                        howItWorks: [
                            "The `def` keyword signals Python that a function definition begins.",
                            "`calculate_area` is assigned as the function identifier in memory.",
                            "Parameters `width` and `height` accept incoming arguments.",
                            "The indented block executes only when the function is invoked."
                        ],
                        parameters: [
                            { name: "function_name", type: "identifier", desc: "Name used to call the function later." },
                            { name: "parameters", type: "variables", desc: "Optional inputs passed into the function." }
                        ],
                        returnValue: "Callable Function Object",
                        commonMistakes: "Forgetting the colon `:` at the end of the `def` header line or inconsistent 4-space indentation.",
                        realWorldUse: "Organizing business logic into modular, readable, and unit-testable code components.",
                        relatedTopics: ["py-return", "py-lambda"]
                    },
                    {
                        id: "py-return",
                        name: "return",
                        type: "keyword",
                        shortDesc: "Exits a function and passes back a result value",
                        difficulty: "Easy",
                        whatIsIt: "The `return` statement immediately terminates function execution and transfers control (along with an optional evaluation result) back to the caller.",
                        syntax: "return expression",
                        codeExample: `def add_numbers(a, b):
    return a + b

sum_result = add_numbers(15, 25)
print("Sum is:", sum_result)`,
                        expectedOutput: "Sum is: 40",
                        howItWorks: [
                            "Evaluates the expression following `return`.",
                            "Immediately halts execution inside the function body.",
                            "Passes the computed result value back to the call location."
                        ],
                        parameters: [
                            { name: "expression", type: "Any", desc: "Value or object returned back to the caller." }
                        ],
                        returnValue: "Specified Object (or None if empty)",
                        commonMistakes: "Placing executable code directly after a `return` statement (dead code that will never run).",
                        realWorldUse: "Returning computed calculations, database records, or status flags from utility functions.",
                        relatedTopics: ["py-def"]
                    }
                ]
            },
            {
                id: "control-flow",
                title: "Conditions & Loops",
                topics: [
                    {
                        id: "py-if-elif-else",
                        name: "if / elif / else",
                        type: "keyword",
                        shortDesc: "Conditional branching logic control",
                        difficulty: "Easy",
                        whatIsIt: "Conditional statements execute specific code blocks depending on whether boolean expressions evaluate to True or False.",
                        syntax: "if condition1:\n    # code\nelif condition2:\n    # code\nelse:\n    # default code",
                        codeExample: `score = 85

if score >= 90:
    grade = "A"
elif score >= 80:
    grade = "B"
else:
    grade = "C"

print(f"Final Grade: {grade}")`,
                        expectedOutput: "Final Grade: B",
                        howItWorks: [
                            "Evaluates the `if` condition first.",
                            "If True, executes its indented block and skips all subsequent branches.",
                            "If False, checks each `elif` sequentially until one evaluates to True.",
                            "Executes `else` if all preceding conditions evaluated to False."
                        ],
                        parameters: [],
                        returnValue: "None",
                        commonMistakes: "Using assignment `=` instead of equality operator `==` inside conditions.",
                        realWorldUse: "User permission checks, input validations, routing logic, and decision making.",
                        relatedTopics: ["py-for", "py-while"]
                    },
                    {
                        id: "py-for",
                        name: "for loop",
                        type: "keyword",
                        shortDesc: "Iterates over elements in a sequence",
                        difficulty: "Easy",
                        whatIsIt: "A `for` loop iterates over items of any sequence (such as a list, tuple, dictionary, set, or string) in order.",
                        syntax: "for item in sequence:\n    # process item",
                        codeExample: `languages = ["Python", "JavaScript", "Rust"]

for index, lang in enumerate(languages, start=1):
    print(f"{index}. {lang}")`,
                        expectedOutput: `1. Python
2. JavaScript
3. Rust`,
                        howItWorks: [
                            "Requests an iterator from the given sequence.",
                            "Assigns each next element to the loop variable (`item`).",
                            "Executes the loop body for every item until the sequence is exhausted."
                        ],
                        parameters: [],
                        returnValue: "None",
                        commonMistakes: "Modifying a list while actively iterating over it with a `for` loop.",
                        realWorldUse: "Processing collections of data, transforming lists, and rendering items in UI grids.",
                        relatedTopics: ["py-while", "py-range"]
                    }
                ]
            }
        ]
    },

    javascript: {
        id: "javascript",
        name: "JavaScript",
        category: "web",
        tagline: "Web Development • Interactive",
        badge: "Essential",
        color: "#F7DF1E",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M3 3h18v18H3V3zm10.5 13.5v-1.8c0-.6.4-.8 1-.8.8 0 .9.5.9 1.1 0 .8-.5 1.4-1.3 1.9-1.2.7-2.6.3-3.1-.7-.3-.6-.3-1.4-.3-2.1v-4.1h1.9v4.1c0 .4 0 .8.2 1 .3.4.8.5 1.2.5zM7.5 16.5c-.8 0-1.4-.4-1.6-1.1h1.8c.1.3.4.5.8.5.5 0 .8-.3.8-.7 0-.5-.3-.7-1-.9-1.1-.4-1.8-.8-1.8-1.9 0-1.1.9-1.9 2-1.9 1.1 0 1.8.6 2 1.4h-1.8c-.1-.3-.3-.5-.7-.5-.4 0-.6.2-.6.5 0 .4.3.6 1 .9 1.2.4 1.8.9 1.8 2 0 1.1-.9 1.7-2.1 1.7z"/></svg>`,
        description: "The core programming language of the web, powering frontend UI interactivity and backend Node.js servers.",
        categories: [
            {
                id: "js-basics",
                title: "Basics & Variables",
                topics: [
                    {
                        id: "js-console-log",
                        name: "console.log()",
                        type: "function",
                        shortDesc: "Outputs messages to the web developer console",
                        difficulty: "Easy",
                        whatIsIt: "Prints formatted strings, variables, or JavaScript objects to the browser developer tools console or Node.js stdout.",
                        syntax: "console.log(obj1, obj2, ..., objN);",
                        codeExample: `const user = { name: "Sarah", role: "Frontend Dev" };
console.log("Logged User:", user);
console.log(\`Status: Active for \${user.name}\`);`,
                        expectedOutput: `Logged User: { name: "Sarah", role: "Frontend Dev" }
Status: Active for Sarah`,
                        howItWorks: [
                            "Receives any number of arguments.",
                            "Formats object literals into expandable tree structures.",
                            "Outputs the serialized line to dev console stream."
                        ],
                        parameters: [
                            { name: "...data", type: "any", desc: "Objects or values to output." }
                        ],
                        returnValue: "undefined",
                        commonMistakes: "Leaving debugging `console.log()` statements in production build code.",
                        realWorldUse: "Inspecting object states, tracking API payload responses, and quick error debugging.",
                        relatedTopics: ["js-const-let", "js-template-literals"]
                    },
                    {
                        id: "js-const-let",
                        name: "const & let",
                        type: "keyword",
                        shortDesc: "Block-scoped variable declarations",
                        difficulty: "Easy",
                        whatIsIt: "Modern variable declaration keywords in ES6. `const` creates read-only immutable bindings, while `let` permits variable re-assignment.",
                        syntax: "const CONSTANT_NAME = value;\nlet variableName = initialValue;",
                        codeExample: `const maxAttempts = 3;
let currentScore = 10;

currentScore += 5; // Valid
console.log("Score:", currentScore);
console.log("Max Attempts:", maxAttempts);`,
                        expectedOutput: `Score: 15
Max Attempts: 3`,
                        howItWorks: [
                            "Both create block-scoped identifiers bounded by `{}` brackets.",
                            "`const` prevents re-assigning the variable reference identifier.",
                            "`let` permits value mutations throughout scope lifespan."
                        ],
                        parameters: [],
                        returnValue: "undefined",
                        commonMistakes: "Trying to reassign a `const` variable or using legacy global `var`.",
                        realWorldUse: "Ensuring clean variable scoping and preventing accidental state mutations.",
                        relatedTopics: ["js-functions", "js-arrow-functions"]
                    }
                ]
            },
            {
                id: "js-async",
                title: "Async & Promises",
                topics: [
                    {
                        id: "js-fetch",
                        name: "fetch()",
                        type: "function",
                        shortDesc: "Asynchronously fetches HTTP network resources",
                        difficulty: "Medium",
                        whatIsIt: "The Fetch API provides a modern JavaScript interface for fetching resources asynchronously across the network.",
                        syntax: "fetch(url, options).then(res => res.json())",
                        codeExample: `async function loadUserData() {
    // Simulated async fetch response
    const mockUser = { id: 101, username: "dev_genius" };
    console.log("Fetched User:", mockUser.username);
}

loadUserData();`,
                        expectedOutput: "Fetched User: dev_genius",
                        howItWorks: [
                            "Initiates an asynchronous HTTP request.",
                            "Returns a Promise that resolves to a Response object.",
                            "Calling `.json()` parses the JSON response body asynchronously."
                        ],
                        parameters: [
                            { name: "resource", type: "string | Request", desc: "Target endpoint URL." },
                            { name: "options", type: "object", desc: "HTTP methods, headers, body, etc." }
                        ],
                        returnValue: "Promise<Response>",
                        commonMistakes: "Forgetting that `fetch()` does not reject on HTTP error status codes like 404 or 500.",
                        realWorldUse: "Connecting single-page web applications (SPAs) to RESTful API backends.",
                        relatedTopics: ["js-async-await", "js-promises"]
                    }
                ]
            }
        ]
    },

    dart: {
        id: "dart",
        name: "Dart",
        category: "mobile",
        tagline: "Flutter Development • Cross-Platform",
        badge: "Flutter",
        color: "#0175C2",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M4.1 12.5L12 4.6l7.9 7.9-7.9 7.9-7.9-7.9zm0 0l3.9-3.9 4 4-4 4-3.9-4.1z"/></svg>`,
        description: "Client-optimized language for fast apps on any platform, powering Flutter for iOS, Android, and Web.",
        categories: [
            {
                id: "dart-basics",
                title: "Basics & Types",
                topics: [
                    {
                        id: "dart-main",
                        name: "main()",
                        type: "function",
                        shortDesc: "Entry point for every Dart application",
                        difficulty: "Easy",
                        whatIsIt: "Every Dart app requires a top-level `main()` function, which serves as the execution starting point.",
                        syntax: "void main() {\n  // Code starts here\n}",
                        codeExample: `void main() {
  String appName = "Flutter Hub";
  print("Launching $appName...");
}`,
                        expectedOutput: "Launching Flutter Hub...",
                        howItWorks: [
                            "Dart runtime invokes `main()` first when starting the executable.",
                            "Arguments can optionally be received via `List<String> args`."
                        ],
                        parameters: [
                            { name: "args", type: "List<String>", desc: "Optional command-line arguments." }
                        ],
                        returnValue: "void",
                        commonMistakes: "Omitting the `main()` top-level function in Dart entry scripts.",
                        realWorldUse: "Initializing Flutter widgets, state stores, and entry services.",
                        relatedTopics: ["dart-variables", "dart-classes"]
                    }
                ]
            }
        ]
    },

    java: {
        id: "java",
        name: "Java",
        category: "backend",
        tagline: "Enterprise • Cross-Platform",
        badge: "Enterprise",
        color: "#5382A1",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M8.8 17.5s1.2.9 3.2.9c2.4 0 4.1-1.3 4.1-3.2 0-2.3-2.1-3.1-4.2-3.8-2.2-.7-3.2-1.4-3.2-2.5 0-1.2 1.1-2 2.8-2 1.6 0 3 .6 3 .6l.6-1.7s-1.4-.7-3.6-.7c-2.7 0-4.5 1.5-4.5 3.6 0 2.2 1.9 3.1 4.1 3.7 2.3.7 3.3 1.4 3.3 2.7 0 1.3-1.3 2.1-3.2 2.1-2.1 0-3.8-.9-3.8-.9l-.6 1.7z"/></svg>`,
        description: "Class-based object-oriented programming language built for reliability, enterprise scale, and Android apps.",
        categories: [
            {
                id: "java-basics",
                title: "Core Java",
                topics: [
                    {
                        id: "java-sout",
                        name: "System.out.println()",
                        type: "method",
                        shortDesc: "Prints line output to standard console",
                        difficulty: "Easy",
                        whatIsIt: "Standard output stream method in Java used to print values followed by a newline.",
                        syntax: "System.out.println(data);",
                        codeExample: `public class Main {
    public static void main(String[] args) {
        String lang = "Java 21";
        System.out.println("Hello from " + lang);
    }
}`,
                        expectedOutput: "Hello from Java 21",
                        howItWorks: [
                            "Accesses static member `out` of class `System`.",
                            "Invokes `println()` to send character bytes to console."
                        ],
                        parameters: [{ name: "msg", type: "Object", desc: "Content to print." }],
                        returnValue: "void",
                        commonMistakes: "Forgetting semicolon `;` or using lowercase for `System`.",
                        realWorldUse: "Console output logging and enterprise debugging.",
                        relatedTopics: ["java-classes"]
                    }
                ]
            }
        ]
    },

    c: {
        id: "c",
        name: "C",
        category: "backend",
        tagline: "System Programming • High Performance",
        badge: "Systems",
        color: "#A8B9CC",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm3.5 13.5c-.8.8-2 1.3-3.5 1.3-2.8 0-5-2.2-5-5s2.2-5 5-5c1.5 0 2.7.5 3.5 1.3l-1.4 1.4c-.5-.5-1.2-.8-2.1-.8-1.7 0-3 1.3-3 3s1.3 3 3 3c.9 0 1.6-.3 2.1-.8l1.4 1.4z"/></svg>`,
        description: "The foundational procedural language powering operating systems, hardware drivers, and embedded devices.",
        categories: [
            {
                id: "c-basics",
                title: "Standard I/O & Memory",
                topics: [
                    {
                        id: "c-printf",
                        name: "printf()",
                        type: "function",
                        shortDesc: "Formatted output to stdout",
                        difficulty: "Easy",
                        whatIsIt: "Standard library function in C (`<stdio.h>`) used to print formatted strings.",
                        syntax: "printf(\"format string\", arg1, arg2);",
                        codeExample: `#include <stdio.h>

int main() {
    int age = 24;
    printf("DevSyntax Age: %d years\\n", age);
    return 0;
}`,
                        expectedOutput: "DevSyntax Age: 24 years",
                        howItWorks: ["Replaces `%d` format specifiers with corresponding variable arguments."],
                        parameters: [{ name: "format", type: "const char*", desc: "Format string specifier." }],
                        returnValue: "int (number of printed characters)",
                        commonMistakes: "Mismatched format specifiers (e.g., using `%f` for integers).",
                        realWorldUse: "Low-level system diagnostic logging and embedded firmware.",
                        relatedTopics: ["c-pointers"]
                    }
                ]
            }
        ]
    },

    cpp: {
        id: "cpp",
        name: "C++",
        category: "backend",
        tagline: "Game Engines • High Performance",
        badge: "Performance",
        color: "#00599C",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm2 11h-1v1a1 1 0 0 1-2 0v-1h-1a1 1 0 0 1 0-2h1v-1a1 1 0 0 1 2 0v1h1a1 1 0 0 1 0 2zm4 0h-1v1a1 1 0 0 1-2 0v-1h-1a1 1 0 0 1 0-2h1v-1a1 1 0 0 1 2 0v1h1a1 1 0 0 1 0 2z"/></svg>`,
        description: "High-performance OOP language widely used in 3D game engines, system graphics, and desktop applications.",
        categories: [
            {
                id: "cpp-basics",
                title: "I/O Streams & STL",
                topics: [
                    {
                        id: "cpp-cout",
                        name: "std::cout",
                        type: "stream",
                        shortDesc: "Standard output stream object",
                        difficulty: "Easy",
                        whatIsIt: "Standard output stream object in C++ defined inside `<iostream>`.",
                        syntax: "std::cout << expression1 << expression2;",
                        codeExample: `#include <iostream>

int main() {
    std::cout << "Engine status: " << "OPTIMAL" << std::endl;
    return 0;
}`,
                        expectedOutput: "Engine status: OPTIMAL",
                        howItWorks: ["Overloads stream insertion operator `<<` to format values."],
                        parameters: [],
                        returnValue: "std::ostream&",
                        commonMistakes: "Forgetting `using namespace std;` or omitting `std::` prefix.",
                        realWorldUse: "High speed console feedback in game physics loops.",
                        relatedTopics: ["cpp-classes"]
                    }
                ]
            }
        ]
    },

    csharp: {
        id: "csharp",
        name: "C#",
        category: "backend",
        tagline: "Unity Gaming • .NET Enterprise",
        badge: ".NET",
        color: "#239120",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 14h-2v-2h2v2zm0-4h-2V7h2v5z"/></svg>`,
        description: "Modern component-oriented language developed by Microsoft for .NET web backends and Unity 3D game development.",
        categories: [
            {
                id: "cs-basics",
                title: ".NET Fundamentals",
                topics: [
                    {
                        id: "cs-writeline",
                        name: "Console.WriteLine()",
                        type: "method",
                        shortDesc: "Outputs data followed by current line terminator",
                        difficulty: "Easy",
                        whatIsIt: "Standard library console output method in C# System namespace.",
                        syntax: "Console.WriteLine(value);",
                        codeExample: `using System;

class Program {
    static void Main() {
        Console.WriteLine("C# .NET Core Engine Active");
    }
}`,
                        expectedOutput: "C# .NET Core Engine Active",
                        howItWorks: ["Writes textual representation of value to standard output stream."],
                        parameters: [{ name: "value", type: "object", desc: "Data to print." }],
                        returnValue: "void",
                        commonMistakes: "Capitalization errors (C# is strictly case-sensitive).",
                        realWorldUse: "Unity game engine debug console logging.",
                        relatedTopics: ["cs-linq"]
                    }
                ]
            }
        ]
    },

    go: {
        id: "go",
        name: "Go",
        category: "backend",
        tagline: "Cloud Native • Microservices",
        badge: "Cloud",
        color: "#00ADD8",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>`,
        description: "Open source language engineered at Google for scalable concurrent backend systems and microservices.",
        categories: [
            {
                id: "go-basics",
                title: "Goroutines & Packages",
                topics: [
                    {
                        id: "go-fmt-println",
                        name: "fmt.Println()",
                        type: "function",
                        shortDesc: "Formats according to default specifiers and prints",
                        difficulty: "Easy",
                        whatIsIt: "Standard printing function provided by Go's `fmt` package.",
                        syntax: "fmt.Println(a ...any)",
                        codeExample: `package main
import "fmt"

func main() {
    fmt.Println("Go Cloud Server Running on Port 8080")
}`,
                        expectedOutput: "Go Cloud Server Running on Port 8080",
                        howItWorks: ["Formats arguments with default space separators and appends a newline."],
                        parameters: [{ name: "a", type: "...any", desc: "Values to print." }],
                        returnValue: "(n int, err error)",
                        commonMistakes: "Forgetting to import `\"fmt\"` package.",
                        realWorldUse: "Docker & Kubernetes microservice logging.",
                        relatedTopics: ["go-goroutines"]
                    }
                ]
            }
        ]
    },

    rust: {
        id: "rust",
        name: "Rust",
        category: "backend",
        tagline: "Memory Safety • High Speed",
        badge: "Blazing Fast",
        color: "#CE412B",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2L2 19h20L12 2zm0 3.8L18.5 17H5.5L12 5.8z"/></svg>`,
        description: "Empowering everyone to build reliable and efficient software with zero-cost abstractions and memory safety.",
        categories: [
            {
                id: "rust-basics",
                title: "Ownership & Macros",
                topics: [
                    {
                        id: "rust-println-macro",
                        name: "println!",
                        type: "macro",
                        shortDesc: "Prints formatted string macro to stdout",
                        difficulty: "Easy",
                        whatIsIt: "Built-in declarative macro in Rust used for console output with string formatting.",
                        syntax: "println!(\"Formatted: {}\", value);",
                        codeExample: `fn main() {
    let speed = "Blazing Fast";
    println!("Rust is {}!", speed);
}`,
                        expectedOutput: "Rust is Blazing Fast!",
                        howItWorks: ["Checked at compile-time to guarantee type-safe string formatting."],
                        parameters: [{ name: "format", type: "literal", desc: "Interpolation string format." }],
                        returnValue: "()",
                        commonMistakes: "Omitting the exclamation mark `!` (required for macros).",
                        realWorldUse: "WebAssembly binaries, crypto node validation, and high performance servers.",
                        relatedTopics: ["rust-ownership"]
                    }
                ]
            }
        ]
    },

    php: {
        id: "php",
        name: "PHP",
        category: "backend",
        tagline: "Web Server • Dynamic Scripts",
        badge: "Web Backends",
        color: "#777BB4",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>`,
        description: "Popular server-side scripting language designed for web development, powering platforms like WordPress & Laravel.",
        categories: [
            {
                id: "php-basics",
                title: "Server Scripts",
                topics: [
                    {
                        id: "php-echo",
                        name: "echo",
                        type: "language construct",
                        shortDesc: "Outputs one or more strings to the web response stream",
                        difficulty: "Easy",
                        whatIsIt: "Primary output construct in PHP for rendering HTML or text content.",
                        syntax: "echo $string_data;",
                        codeExample: `<?php
$framework = "Laravel";
echo "Serving application with " . $framework;
?>`,
                        expectedOutput: "Serving application with Laravel",
                        howItWorks: ["Sends raw string content directly to HTTP output response buffer."],
                        parameters: [],
                        returnValue: "void",
                        commonMistakes: "Forgetting string concatenation dot operator `.`.",
                        realWorldUse: "Rendering dynamic web templates.",
                        relatedTopics: ["php-arrays"]
                    }
                ]
            }
        ]
    },

    ruby: {
        id: "ruby",
        name: "Ruby",
        category: "backend",
        tagline: "Developer Happiness • Rails",
        badge: "Web Frameworks",
        color: "#CC342D",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2L2 9l10 13 10-13-10-7zm0 3l6 4.5L12 18 6 9.5 12 5z"/></svg>`,
        description: "Dynamic, open source programming language with a focus on simplicity and productivity, famous for Ruby on Rails.",
        categories: [
            {
                id: "ruby-basics",
                title: "Syntax & Blocks",
                topics: [
                    {
                        id: "ruby-puts",
                        name: "puts",
                        type: "method",
                        shortDesc: "Prints string with trailing newline",
                        difficulty: "Easy",
                        whatIsIt: "Standard IO output method in Ruby.",
                        syntax: "puts \"Hello World\"",
                        codeExample: `app_name = "DevSyntax Ruby"
puts "Running #{app_name}"`,
                        expectedOutput: "Running DevSyntax Ruby",
                        howItWorks: ["Writes string representation and appends a newline if absent."],
                        parameters: [],
                        returnValue: "nil",
                        commonMistakes: "Confusing `puts` with `print` (which does not add a newline).",
                        realWorldUse: "Rails server console logs.",
                        relatedTopics: ["ruby-blocks"]
                    }
                ]
            }
        ]
    },

    kotlin: {
        id: "kotlin",
        name: "Kotlin",
        category: "mobile",
        tagline: "Android Development • Modern JVM",
        badge: "Android First",
        color: "#7F52FF",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M2 2h20L12 12 22 22H2V2z"/></svg>`,
        description: "Modern cross-platform, statically typed programming language recommended by Google for Android app development.",
        categories: [
            {
                id: "kotlin-basics",
                title: "Modern Concise Syntax",
                topics: [
                    {
                        id: "kt-println",
                        name: "println()",
                        type: "function",
                        shortDesc: "Prints given message to standard output",
                        difficulty: "Easy",
                        whatIsIt: "Top-level Kotlin function for console printing.",
                        syntax: "println(message)",
                        codeExample: `fun main() {
    val dev = "Android Engineer"
    println("Welcome, $dev!")
}`,
                        expectedOutput: "Welcome, Android Engineer!",
                        howItWorks: ["Interprets string templates `$variable` and outputs line."],
                        parameters: [],
                        returnValue: "Unit",
                        commonMistakes: "Using `new` keyword (Kotlin does not use `new` for class instances).",
                        realWorldUse: "Android Jetpack Compose UI debugging.",
                        relatedTopics: ["kt-coroutines"]
                    }
                ]
            }
        ]
    },

    swift: {
        id: "swift",
        name: "Swift",
        category: "mobile",
        tagline: "iOS & macOS • SwiftUI",
        badge: "Apple Ecosystem",
        color: "#F05138",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M19.8 14c-.6 1.4-2.1 3.5-4.2 5.1 2.3-1 4.2-2.7 5.2-4.5-1 0-1-.6-1-.6zM12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2z"/></svg>`,
        description: "Powerful and intuitive programming language for iOS, iPadOS, macOS, tvOS, and watchOS development.",
        categories: [
            {
                id: "swift-basics",
                title: "iOS Fundamentals",
                topics: [
                    {
                        id: "swift-print",
                        name: "print()",
                        type: "function",
                        shortDesc: "Writes textual representation to output stream",
                        difficulty: "Easy",
                        whatIsIt: "Standard Swift printing function.",
                        syntax: "print(\"Text \\(variable)\")",
                        codeExample: `let device = "iPhone 15 Pro"
print("Testing on \\(device)")`,
                        expectedOutput: "Testing on iPhone 15 Pro",
                        howItWorks: ["Uses string interpolation `\\(expr)` to output formatted logs."],
                        parameters: [],
                        returnValue: "Void",
                        commonMistakes: "Using `#` instead of `\\()` for string interpolation.",
                        realWorldUse: "Xcode console debugging.",
                        relatedTopics: ["swift-optionals"]
                    }
                ]
            }
        ]
    },

    html: {
        id: "html",
        name: "HTML",
        category: "web",
        tagline: "Web Structure • Markup Language",
        badge: "Web Core",
        color: "#E34F26",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M1.5 0h21l-1.9 21.2L12 24l-8.6-2.8L1.5 0zm16.7 5.8H6.5l.3 3.5h10.8l-.5 5.7-5.1 1.4-5.1-1.4-.3-3.8H3.2l.6 7.4 8.2 2.3 8.2-2.3 1.1-12.8z"/></svg>`,
        description: "The standard markup language used to structure web pages and content for browser display.",
        categories: [
            {
                id: "html-elements",
                title: "Document Structure & Elements",
                topics: [
                    {
                        id: "html-div",
                        name: "<div>",
                        type: "element",
                        shortDesc: "Generic division / section container element",
                        difficulty: "Easy",
                        whatIsIt: "The `<div>` tag defines a division or a container section in an HTML document.",
                        syntax: "<div class=\"container\">\n  <!-- child content -->\n</div>",
                        codeExample: `<div class="card">
  <h2>DevSyntax Web</h2>
  <p>Interactive HTML learning component.</p>
</div>`,
                        expectedOutput: "DevSyntax Web\nInteractive HTML learning component.",
                        howItWorks: ["Acts as a block-level wrapper for CSS styling and layout structuring."],
                        parameters: [],
                        returnValue: "HTMLDivElement",
                        commonMistakes: "Overusing `<div>` tags instead of semantic elements like `<header>`, `<main>`, or `<article>`.",
                        realWorldUse: "Structuring CSS flexbox and grid layouts.",
                        relatedTopics: ["html-semantic"]
                    }
                ]
            }
        ]
    },

    css: {
        id: "css",
        name: "CSS",
        category: "web",
        tagline: "Web Design • Styles & Animations",
        badge: "Styling",
        color: "#1572B6",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M1.5 0h21l-1.9 21.2L12 24l-8.6-2.8L1.5 0zm16.7 5.8H6.5l.3 3.5h10.8l-.5 5.7-5.1 1.4-5.1-1.4-.3-3.8H3.2l.6 7.4 8.2 2.3 8.2-2.3 1.1-12.8z"/></svg>`,
        description: "Style sheet language used for describing the presentation, layout, colors, and responsive design of HTML documents.",
        categories: [
            {
                id: "css-layouts",
                title: "Flexbox & Grid Layouts",
                topics: [
                    {
                        id: "css-flexbox",
                        name: "display: flex",
                        type: "property",
                        shortDesc: "Activates flexible box layout model",
                        difficulty: "Easy",
                        whatIsIt: "CSS rule that converts a container into a flexible flexbox layout context.",
                        syntax: ".container {\n  display: flex;\n  justify-content: center;\n  align-items: center;\n}",
                        codeExample: `/* Flexbox Centering Rule */
.hero-box {
  display: flex;
  justify-content: space-between;
  align-items: center;
}`,
                        expectedOutput: "[Flex Box layout rendered with centered elements]",
                        howItWorks: ["Aligns child flex items dynamically along primary and cross axes."],
                        parameters: [],
                        returnValue: "CSS Style Rule",
                        commonMistakes: "Confusing `justify-content` (main axis) with `align-items` (cross axis).",
                        realWorldUse: "Creating responsive navigation bars, cards, and adaptive grids.",
                        relatedTopics: ["css-grid"]
                    }
                ]
            }
        ]
    },

    sql: {
        id: "sql",
        name: "SQL",
        category: "backend",
        tagline: "Databases • Queries & Analytics",
        badge: "Data & DB",
        color: "#4479A1",
        iconSvg: `<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z"/></svg>`,
        description: "Standard domain-specific language used to manage, query, and manipulate relational database management systems.",
        categories: [
            {
                id: "sql-queries",
                title: "Data Querying",
                topics: [
                    {
                        id: "sql-select",
                        name: "SELECT",
                        type: "keyword",
                        shortDesc: "Queries data from database tables",
                        difficulty: "Easy",
                        whatIsIt: "The `SELECT` statement retrieves zero or more rows from relational database tables.",
                        syntax: "SELECT column1, column2 FROM table_name WHERE condition;",
                        codeExample: `SELECT user_id, username, role
FROM users
WHERE status = 'ACTIVE'
ORDER BY created_at DESC;`,
                        expectedOutput: `+---------+--------------+--------------+
| user_id | username     | role         |
+---------+--------------+--------------+
| 108     | alex_dev     | Admin        |
| 105     | sarah_code   | Developer    |
+---------+--------------+--------------+`,
                        howItWorks: [
                            "Scans table specified in `FROM` clause.",
                            "Filters matching rows using `WHERE` conditions.",
                            "Returns specified column set in recordset format."
                        ],
                        parameters: [],
                        returnValue: "Result Set Table",
                        commonMistakes: "Using `SELECT *` in production web API endpoints (fetches unnecessary column bytes).",
                        realWorldUse: "Fetching data for API responses, business intelligence reports, and authentication queries.",
                        relatedTopics: ["sql-join"]
                    }
                ]
            }
        ]
    }
};

if (typeof module !== 'undefined' && module.exports) {
    module.exports = LANGUAGES_DATA;
}
