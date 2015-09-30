---
layout: post
title: "Context free grammar will help where regex pattern fail - Is this well formed array ?"
date: 2015-08-17 00:04:55 +0200
comments: true
categories: [java, pattern, context free grammar]
---

###Preface
Some times ago I was scanning Stackoverflow to find a puzzle to solve, and I found one guy was trying to write a piece of software which had needed to answer on one simple question. Is given expression a **well formed array**? He was searching for a ready to use regular expression but he failed, because this puzzle can't be solved using regex engine. Why, I will explain later but now I can say that this puzzle can be easily solved using **Context free grammar**. 

###Well formed array
You can ask what does the **well formed array** mean ? I will try to answer by providing some positive and negative examples of such arrays.
```
[1 2 [-34 7] 34]
[1 2 [-34] [7] 34]
[1 2 [-34 [7] 34]]
[1 2[-34[7]34]]
[]
[[[]]]
```
Above are well formed arrays. In opposite below are expressions which are not syntactically consistent with the definition of well formed array.
```
[1 2 -34 7] 34]
[1 2 [-34 [7] 34]
[][]

```
Studying those examples we can try to answer on this question. So well formed array is an expression which fulfills following requirements

* first, no blank, character is an open brace ``'['``
* the last no blank character needs to be a closed brace
* inside array, integers and other well formed arrays can appear
* integers are separated with at least one blank character

###Why not regex ?
Let's simplified our example. Let's say that we want to write a regular expression which will generate following words $$w=( [^n\quad ]^n\quad|\quad n >= 1 )$$
```
[]
[[]]
[[]]
[[[]]]
```
You can notice that the mention above strings are a subset of the set of strings which we want to parse. And here I don't have also good news. We can't use regex engine to parse such strings.
Why is it not possible ? Simply speaking regex engine modeled by a **Finite Automata (FA)** can't count how many ``'['`` we have already used and check that the same number of ``']'`` must appear just after the last ``'['``. **FA** doesn't have stack to remember such things. If You are curious about formal proof you can try to google **Pumping Lemma** phrase. **Pumping Lemma** provides You a useful tool to proof if a given language (set of words which fulfill given conditions) is not a regular.

###Context free grammar
I have already mentioned that to solve our problem (if a given array is well formed) we need to write a parser of some **context free grammar**. The model of **Context free grammar** is a **Finite Automata** with a **stack**. Thanks to this an Automat is able to remember some facts that have happened (e.g count braces). To write a parser we need first to write down a grammar for expression of **well formed array**. To do this I will use **ebnf** (Extended Backus–Naur Form) form.
```
array = "[", { array-body }, "]" 
array-body = number | array
number = [ "-" ], digit, { digit }
digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
```
Now we are ready to write a parser.  To be precise I will use top-down parsing strategy which let me directly transform written above grammar into set of recursively called procedures.

###Parser

It is a good manner to split parser into 2 parts

* lexer
* parser

Lexer is responsible for grouping letters into tokens. In our grammar we have 4 kinds of tokens

* ``'['`` (**LB**)
* ``']'`` (**RB**)
* number (**NUMBER**)
* end - token informing that there is no letter left on input  (**END**)

Tokens are expressed by a class ``Token`` written below

```java
public class Token {

    public enum Type {
        LB, RB, NUMBER, END
    }

    private final Type type;
    private final String value;

    public Token(Type type, String value) {
        this.type = type;
        this.value = value;
    }

    public Type getType() {
        return type;
    }

    public String getValue() {
        return value;
    }

    @Override
    public String toString() {
        final StringBuilder sb = new StringBuilder("Token[");
        sb.append("type=").append(type);
        sb.append(", value='").append(value).append('\'');
        sb.append(']');
        return sb.toString();
    }
}
```

####Lexer
```java
public class Lexer {

    private int current;
    private String input;

    public Lexer(String input) {
        this.input = input;
    }

    private char getChar() {
        return input.charAt(current++);
    }

    private void unputChar() {
        current--;
    }

    private boolean hasNextChar() {
        return current < input.length();
    }

    public Token next() {

        if (!hasNextChar()) {
            return new Token(Type.END, "");
        }

        char c = getChar();

        while (Character.isWhitespace(c)) {
            c = getChar();
        }

        if (c == '[') {
            return new Token(Type.LB, "[");
        }

        if (c == ']') {
            return new Token(Type.RB, "]");
        }

        int s = 1;
        if (c == '-') {
            s = -1;
        } else {
            unputChar();
        }

        StringBuilder buffer = new StringBuilder();
        while (hasNextChar()) {

            c = getChar();

            if (Character.isDigit(c)) {
                buffer.append(c);
            } else {
                unputChar();
                break;
            }

        }

        return new Token(Type.NUMBER, s > 0 ? buffer.toString() : "-" + buffer.toString());

    }

}
```
####Parser
```java
public class Parser {

    private Lexer lexer;
    private Token currentToken;

    private boolean match(Type type) {
        return type == currentToken.getType();
    }

    private void consume(Type type) {
        if (!match(type)) {
            throw new RuntimeException(String.format("Should be %s is %s", type.name(), currentToken.getType().name()));
        }
        currentToken = lexer.next();
    }

    private void array() {

        consume(Type.LB);

        while (true) {

            if (match(Type.NUMBER)) {
                consume(Type.NUMBER);
            } else if (match(Type.LB)) {
                array();
            } else {
                break;
            }

        }

        consume(Type.RB);
    }


    private void parse(String line) {

        lexer = new Lexer(line);
        currentToken = lexer.next();

        array();
        consume(Type.END);

    }

    public boolean isWellFormedArray(String line) {

        try {
            parse(line);
            return true;
        } catch (Exception e) {
            System.out.println(String.format("%s is not a proper array because %s", line, e.getMessage()));
            return false;
        }

    }

}
```
###Test
```java
public class ParserTest {

    @Test
    public void testIsWellFormedArray() throws Exception {

        Parser parser = new Parser();
        assertThat(parser.isWellFormedArray("[1 2 [-34 7] 34]"), equalTo(true));
        assertThat(parser.isWellFormedArray("[1 2 -34 7] 34]"), equalTo(false));
        assertThat(parser.isWellFormedArray("[1 2 [-34] [7] 34]"), equalTo(true));
        assertThat(parser.isWellFormedArray("[1 2 [-34 [7] 34]"), equalTo(false));
        assertThat(parser.isWellFormedArray("[1 2 [-34 [7] 34]]"), equalTo(true));
        assertThat(parser.isWellFormedArray("[]"), equalTo(true));
        assertThat(parser.isWellFormedArray("[][]"), equalTo(false));
        assertThat(parser.isWellFormedArray("[[]]"), equalTo(true));
        assertThat(parser.isWellFormedArray("[1 2[-34[7]34]]"), equalTo(true));

    }
}
```



