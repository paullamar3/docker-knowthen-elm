
# Docker Container for Elm Development

So I enrolled in the *knowthen* course on 
[Elm for Beginners](http://courses.knowthen.com/courses/elm-for-beginners).
After watching the second lecture, *Setting Up the Elm Development
Environment*, I couldn't help but wonder if there wasn't a *Docker* container
out there that would make this process easier. 

> ASIDE: I've recently been trying to put all my development environments into
> containers. That way I don't have to worry about various environments
> interfering with each other. Also, I can pull down the container into any
> machine I'm working on and be assured of getting the same experience.

I found an official container for *Node.js* but nothing for *Elm* and nothing
with both *Node.js* and *Atom* in the same container. (The instructor suggests
using *Atom* as the editor and the lessons seemed to be geared toward *Atom*.
Later, after I finish the course, I'll try to make a comparable *Elm*
development container with *Vim*.) So I put this together.

## This is an interactive container

The first thing to note about this container is that it is built to provide an
interactive environment in which to code. Normally when one thinks of
containers one envisions it containing a single application. However this is
more difficult to accomplish when one wants to "containerize" something like
an IDE. The make tools, linter and language formatting plug-ins of the editor
all expect to find their corresponding language tools within the same file
system the editor lives in. So this container has several applications bundled
within it and has a correspondingly large size.

> ASIDE: Eventually I'll experiment with containerizing the editor and
> development tools in separate containers and getting them to interact
> between containers. For now, though, that adds unnecessary complexity. Also,
> if you have problems getting the language tools to interact with the editor
> it's much easier to debug the issue when everything is in the same
> container.

## How to use the container

This is a normal *Docker* container but I've added a utility shell script to
assist with starting it up. In the
[repository](https://github.com/paullamar3/docker-knowthen-elm) there is a
folder called `utils` containing the shell scripts `Dstart`, `Dxtemp` and
`startelm`.  You want to copy these scripts so that they live somewhere in your
path. I've set up a directory `~/.my_bins` in which I place little scripts like
this.  I then added this directory to the end of my `$PATH` variable.

### Dxtemp and Dstart: The plumbing

> NOTE: You can skip this section and go straight to the section on using 
> the `startelm` script if you like. The *startelm* script uses *Dstart* and 
> *Dxtemp* but you don't need to understand the "plumbing" to use the 
> *startelm* command.

*Dxtemp* is a short script which turns off the X authentication temporarily.
(You can specify the interval by passing in a value that represents the number
of seconds you want the authentication turned off. The default value is 60
seconds.)

*Dstart* wraps some of the plumbing involved in starting a container that is to
be used for developing code. It offers the following features:

* Sets the *Git* global `user.name` and `user.email` in the container to match
  the host's settings.
* Passes information into the container that lets you use the container with
  the same user id and user login name as you have on the host.
* Makes sure the time in the container matches the time on the host.
* Enables the container to use the host's X windows (without having to open up
  the X server to all users with the `xhost` command).
* Uses the new *Docker* `-net` switch so that you can (for example) use your
  host's browser to read from the HTTP server that *Elm* uses. (In this case
the `elm reactor`.)
* Easier mounting of host volumes (which are mounted to the container's
  `/media` folder as if it were a removable device).

Here's an example of how I might use *Dstart* to run my containers:

```
Dstart -tiGg -n my_elm_dev -v "$PWD" paullamar3/docker-knowthen-elm:0.1.1
```

This example assumes that you are issuing the *Dstart* from the directory
containing your project files (or where you want the project files to be) and
that the *Dstart* script is in your path. 

Of course you could start the container using `docker run` but that command
would look something like this:

```
docker run -it -v /etc/localtime:/etc/localtime:ro -e DISPLAY --net=host \
     --name my_elm_dev -v "$PWD:/media/$(basename $PWD)" \
     -d "/media/$(basename $PWD)" \
     paullamar3/docker-knowthen-elm:0.1.1 \
     -u {User name} -U {User ID} -g {Git user name} -e {Git email} 
```

I much prefer to use *Dstart*.

### startelm

The *startelm* script lets you run (via `docker run`) or restart (via 
`docker start`) you *Elm* development. To create and run your *Elm*
container. There are a few different ways to create and run the container.

First, the simplest way: 

```
startelm my_elm_dev
```

Assuming you don't already have a *Docker* container called "my\_elm\_dev",
this command will create a new container of that name. The container should 
launch with the current working directory mounted as a folder in the 
container's `/media/` directory. I cloned the `/knowthen/elm` repository on *GitHub*
into a local folder and then ran *startelm* in that directory so that
I would have all of the exercises accessible to the container. 

An *Atom* editor should open automatically (give it about 10 seconds). The 
terminal from which you ran the *startelm* command will also switch to the 
container and leave you at a bash prompt inside the container.

This approach works fine on my *LMDE* (Linux Mint Debian Edition) computer.
On that computer my user is a member of the `docker` group which means that
I can execute *Docker* commands without using `sudo`.

Second, the slightly more secure way:

```
startelm -s my_elm_dev
```

Use this version of the script if you have chosen *not* to add yourself
to the `docker` group. (If you have to type `sudo docker ...` evertime you
run a *Docker* command then this version is for you.

Third, the "no X authentication" way:

```
startelm -x my_elm_dev
```

While testing this image I discovered that although it works fine
on my *LMDE* machine, the *Atom* processor could not access the 
*X server* when I ran the image on my *Mint 17.3* machine. I spent
a very little bit of time looking into this but could not figure out
why the *Mint 17.3* machine was not sharing its display with the container.
For now I coded a quick hack in the form of the `-x` switch for the 
`startelm` command. Specifying `-x` tells the script to disable the 
*X* authentication on the computer for twenty seconds while the container
is being run (or restarted). Specifying `-x` is a good way to ensure the
container can access you *X server* but it is insecure. For twenty seconds
*anyone* could connect to your *X* windows. I would try running without
`-x` first; only use it if you have to.

> WARNING: The `-x` switch actually runs the `xhost` command to disable and then
> reenable the *X* authentication. If you are the only user of your machine,
> you are *probably* OK. However if you are in a multi-user *Linux* environment 
> you should use the `-x` switch with caution.


> ASIDE: When I run `xhost` on each machine I get back the same results:
> `SI:localuser:{user name}`. So I'm not sure why I need the `-x` switch on one but
> I don't need it on the other. At some point I'll learn more about the *X* authority
> system and see if there is a better way around this issue. For now, though, this
> hack should get us up and running in the mean time.

Of course the `-s` and `-x` switches can be combined into `-sx` if you need both.

### Starting the container the first time

The container should be configured so that you can begin the first set of
exercises (i.e. in the `01 functions` folder). Assuming you started the
container from within this folder or its parent you should be able to type
`atom` in the container to get the *Atom* editor on your desktop. You can then
open the files in that folder and proceed as you normally would.

> NOTE: This container does not have a browser on it. When you get to the part
> where you start `elm reactive`, open the browser on your host and point to
> the `localhost:8000` just as you would do if *Elm* reactive were running on
> your host.

### Progressing through the exercises

After you have finished with the exercise for the day, close *Atom* and then
issue `exit` form the bash shell in the container. This will leave the
container in a "stopped" status. Later you can revisit the container by using
the `docker start` command to pick up where you left off. Any packages you've
installed thus far should still be there in the container. 

Note that you should issue the same *elmstart* command to restart an existing
container that you used to initially create it. The *startelm* script checks
for the container name in the existing containers and simply restarts
the container if it finds it.

### But I *want* to learn how to set *Elm* up myself ...

By using this container you skip having to do the environment setup yourself.
Some people might prefer to set up their own environment from scratch; I
totally get that. Me, I'd rather get into learning the *Elm* language. This
lets me get straight into the programming without having to wrestle with
mundane setup issues or worrying that I might accidentally install something
that will break something else. Instead of having to set up my development
environment on my desktop and my laptop, or in some other virtual machine, I
can simply pull the container and go no matter what machine (virtual or
otherwise) I'm using.

I'm setting this image up in *DockerHub* as an automated build so that you can
see how I built the container. Learning how to set *Elm* up in a container is
(I would argue) more valuable than learning how to set it up normally.

## Work in progress ...

So I've actually used this container (version 0.1.2 as I write this)
to finish the first three sets of exercises. No trouble thus far.
Throughout the rest of the week I'll be finishing the rest of the course and
will make fixes to the container whenever I run across something.
Feel free to try this out and post any issues you find in my repository on
*GitHub*. 

## I did this "for fun"

I'm not affiliated with *Docker*, *knowthen* or *Elm*. I'm just a guy taking
the course. I hope people find this image useful. If you have issues it might
be faster for you to debug them yourself as I will only be checking the
*GitHub* repository about once a week.

All the code used to make this image is in the repository. Later, when I have
more time, I'll post a list of links referencing the wonderful posts about
*Docker* that helped me learn how to put this together. 
