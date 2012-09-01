---
layout: page
title: "Projects"
hidetitle: false
date: 2012-08-28 07:07
comments: false
sharing: false
footer: true
me: true
---

Here are some of the projects I have worked on (or am currently working on).

{% img fancybox right border /stuff/trendweight-chart.png 350 %}

# TrendWeight - Automated Weight Tracking

I am an overweight programmer.  I'm also a sucker for cool gadgets.  In the fall of 2011, when I started to get serious about losing weight, I had the perfect excuse for buying a new toy: a Withings WiFi scale.  And as soon as I got it, I did what a lot of programmer geeks probably have done: I Googled for cool applications to use with the gadget that would let me track my weight loss progress.  When I didn't find anything that I liked, I, of course, decided to write my own.  The result is [trendweight.com](https://trendweight.com).

TrendWeight is a web site that pulls data from Withings or FitBit WiFi-enabled scales and runs it through a series of analyses and then plots a moving average (try the [demo](https://trendweight.com/demo)) so that the user can see how their weight over time is trending instead of worrying about the day to day ups and downs that are the natural result of water retention fluxuation.  It started as a tool that I made just for me to use myself, but when I mentioned it to a couple other people on a weight loss forum, they asked if they could use it and eventually I polished it into a free tool that anyone can use.  TrendWeight as also an excuse for me to play with Windows Azure (it runs as a Windows Azure Web Role and uses SQL Azure for data storage).

[Read more](/trendweight/) about TrendWeight...

<br class="clear" />

{% img fancybox right border /stuff/p2pool.png 350 %}

# P2Pool Stats

Around March of 2011, I got sucked into the world of [Bitcoin](http://bitcoin.org).  Fast forward 9 months, and I had multiple Bitcoin mining rigs in my basement each with multiple GPUs grinding away and earning me Bitcoins.  I don't think I'll try to explain the entirety of Bitcoin here (read the [Wikipedia article](http://en.wikipedia.org/wiki/Bitcoin) for a good summary), but suffice it to say that it is common for multiple people to band together into a community (called "pools") to collaboratively mine Bitcoins.  

Near the end of 2011, I had joined the a pool (called P2Pool) with a relatively unique approach, in that the pool was entirely distributed.  Other pools generally have some centralized server with a back end database that everyone in the community talks to.  As a general rule, these centralized pools, usually have nice looking websites that provide some amount of transparency for the community members so that they can see what the current status is and how much is being earned by each community member.  P2Pool, on the other hand, didn't have this.  It is a completely decentralized pool where all of the community members connect using a peer to peer protocol (hence the name).  Lots of information about what is going with the pool was available, but only in the log files generated on each node of the peer to peer network. 

I decided it would be nice if there was a website that everyone could go to to more easily see what was going on, and so I created [p2pool.info](http://p2pool.info).  As usual, this was also an excuse for me to play with some new technologies.  In this case, I got to do my first serious coding with [Knockout](http://knockoutjs.com), as I decided to make p2pool.info an entirely client side web application that gets all of its data via Ajax web services (which are thin wrappers around a SQL Azure database).

<br class="clear" />
