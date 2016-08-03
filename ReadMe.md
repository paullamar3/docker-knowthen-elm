
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
folder called `utils` containing the shell script `Dstart`. *Dstart* wraps
some of the plumbing involved in starting a container that is to be used for
developing code. It offers the following features:

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

Here's an example of how I use *Dstart* to run my containers:

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

However if you start up a new container with *Dstart* you will have a
container in a "pristine" condition. Some packages and configuration settings
may need to be applied again.

For example, to restart the `my_elm_dev` container once you have exited:

```
docker start -i my_elm_dev
```

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

So I've actually used this container (really version 0.1.0 but I'm redoing the
exercises with this version now) to finish the first set of exercises.
Throughout the rest of the week I'll be finishing the rest of the course and
will make fixes to the container whenever I run across something troublesome.
Feel free to try this out and post any issues you find in my repository on
*GitHub*. Be advised, however, that this project is just started and is "rough
around the edges". Things should be more polished next week.

## I did this "for fun"

I'm not affiliated with *Docker*, *knowthen* or *Elm*. I'm just a guy taking
the course. I hope people find this image useful. If you have issues it might
be faster for you to debug them yourself as I will only be checking the
*GitHub* repository about once a week.

All the code used to make this image is in the repository. Later, when I have
more time, I'll post a list of links referencing the wonderful posts about
*Docker* that helped me learn how to put this together. 
