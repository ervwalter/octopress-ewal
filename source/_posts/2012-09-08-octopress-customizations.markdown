---
layout: post
title: "Octopress Customizations"
date: 2012-09-08 22:22
published: true
comments: true
categories: Octopress
---

This is a very long post, but I wanted to capture the essence of all of the functional changes I made as part of deploying Octopress (excluding look and feel of the site).  If I ever need this information again, it will be easier for me to read this post instead of sifting through a git commit log.  And maybe something in here will be useful to someone else.

Here are the topics covered in this blog post:

- Remove /blog/ from URLs
- Remove line numbers in the Atom feed
- Add categories/tags to posts in the Atom feed
- Creating a categories index page
- Adding support for Clicky Analytics
- Adding support for FancyBox
- Changes to the 'new_post' Rakefile task
- Automatic renaming of post files to have the correct date in them
- Setting up Rake-Rewrite
- Making the 404 page actually return a 404 status
- Notifying Google, Bing, and Ping-o-matic after I make new posts
- Deployming to Heroku using an alternative approach

You can also see these changes in this [GitHub repository](https://github.com/ervwalter/octopress-ewal) if you prefer.

### Remove /blog/ from URLs

This one is pretty simple.  I didn't want /blog/ as a part of any URLs.  There are four changes to make this happen:

1. Change the permalink setting in _config.yml: `permalink: /:year/:month/:day/:title/`
2. Move ./source/blog/articles/index.html to ./source/articles/index.html (and remove the empty ./source/blog/ folder)
3. Updated the "Archives" hyperlink in `./source/_includes/custom/navigation.html`
4. Updated the "Blog Archives" hyperlink in `./source/index.html`

Note, I think /blog/ has been removed from URLs by default in the next version of Octopress (2.1), so this may eventually be unnecessary.

### Remove Line Numbers in Atom Feed

Code snippets in Octopress are nicely formatted with syntax highlighting when you visit the actual web site.  However, that formatting does not appear when a blog post is viewed in an feed reader like Google Reader because the web site's CSS is not getting applied. The result isn't horrible, but one thing that annoyed me was that line numbers still appear but without any padding between the line numbers and the code lines.  I felt the result was actually pretty hard to read.  My solution is to make the line numbers not appear in the Atom version of the post markup.

There are two parts to making this work.  First, I defined a new Liquid filter that looked for the column of line numbers and removes it.  Note, I originally tried just hiding the column, but Google Reader strips out HTML style attributes for security reasons.

``` ruby ./plugins/custom_filters.rb
module CustomLiquidFilters
  def remove_linenumbers(input)
    input.gsub(/\<td\ class="gutter"\>.+?\<\/td\>/m, ' ')
  end
end

Liquid::Template.register_filter CustomLiquidFilters
```

Second, I edited ./source/atom.xml and added the new filter.

{% raw %}
``` xml ./source/atom.xml
  <entry>
    ... other elements ...
    <content type="html"><![CDATA[{{ post.content | remove_linenumbers | expand_urls: site.url | cdata_escape }}]]></content>
  </entry>
```
{% endraw %}

### Categories in the Atom Feed

I also added post category information to the Atom feed. This is also just a couple lines added to ./source/atom.xml.  The tag that is added is normalized so that the scheme + term ends up being the correct URL for that category's index page.

{% raw %}
``` xml ./source/atom.xml
  <entry>
    ... other elements ...
    {% for category in post.categories %}
    <category scheme="{{ site.url }}/categories/" term="{{ category | replace: ' ','-' | downcase }}" />
    {% endfor %}
  </entry>
```
{% endraw %}

### Categories Index Page

I added a [category list](/categories/) page.  This uses the [category_list.rb plugin](https://github.com/alswl/octopress-category-list) by alswl.  For now, I have decided to use a simple unordered list instead of a tag cloud as I think that works better with the small number of categories I have at the moment.

I created a new page at ./source/categories/index.html that uses the plugin.

{% raw %}
``` html ./source/categories/index.html
---
layout: page
title: Categories
footer: true
body_id: categories
date: 2012-08-11 23:20
---

<div>
  <ul id="category-list">{% category_list counter:true %}</ul>
</div>
```
{% endraw %}


### Clicky Analytics

I use [Clicky](http://getclicky.com/66497886) for analytics on all my web sites.  Enabling it for this one was as easy as adding the asynchronous tracking code to ./source/_includes/custom/after_footer.html

``` html ./source/_includes/custom/after_footer.html
<script type="text/javascript">
var clicky_site_ids = clicky_site_ids || [];
clicky_site_ids.push(66633993);
(function() {
  var s = document.createElement('script');
  s.type = 'text/javascript';
  s.async = true;
  s.src = '//static.getclicky.com/js';
  ( document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0] ).appendChild( s );
})();
</script>
``` 

### FancyBox

I use [fancyBox](http://fancyapps.com/fancybox/) with some of my images in blog posts.  The first part of the setup is pretty standard:

1. Add a reference to jquery.fancybox.css in ./source/_includes/custom/head.html
2. Add a reference to jquery.min.js (if it is not already there) in ./source/_includes/custom/after_footer.html
3. Add a reference to jquery.fancybox.pack.js in ./source/_includes/custom/after_footer.html

To actually create blog posts with images that are enabled for fancybox, I use the Octopress [image tag](http://octopress.org/docs/plugins/image-tag/) and include a fancybox css class on images.

{% raw %}
    {% img fancybox /stuff/currentcost-transmitter1.jpg 120 %}
{% endraw %}

That results in an image like this... (click to activate the fancybox light box)

{% img fancybox /stuff/currentcost-transmitter1.jpg 120 %}

I have a bit of javascript that adjusts the generated markup so that it works with fancybox.  It wraps the `<img />` tag with the `<a></a>` tag that fancybox expects.  Any classes on the image tag are moved to the new anchor tag and the caption is copied to the anchor as well.  Also, all of the images in a given post are added to a fancybox gallery.  It's done per-post so that when viewing the main index of the blog, unrelated images don't end up getting added to one large gallery.

``` js
$(function()) {
  $('.entry-content').each(function(i){
    var _i = i;
    $(this).find('img.fancybox').each(function(){
      var img = $(this);
      var title = img.attr("title");
      var classes = img.attr("class");
      img.removeAttr("class");
      img.wrap('<a href="'+this.src+'" class="' + classes + '" rel="gallery'+_i+'" />');
      if (title != "")
      {
        img.parent().attr("title", title);
      }
    });
  });
  $('.fancybox').fancybox();
});
```

### New Post Rake Task 

I have modified the new_post rake task in two ways:

1. New posts are created as draft posts (unpublished) by adding 'published: false' to the new file (line 17 below)
2. New posts open in Sublime Text 2 after they are created (line 22 below)

Here is the modified new_post rake task: 

``` ruby ./Rakefile
desc "Begin a new post in #{source_dir}/#{posts_dir}"
task :new_post, :title do |t, args|
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)
  mkdir_p "#{source_dir}/#{posts_dir}"
  args.with_defaults(:title => 'new-post')
  title = args.title
  filename = "#{source_dir}/#{posts_dir}/#{Time.now.strftime('%Y-%m-%d')}-#{title.to_url}.#{new_post_ext}"
  if File.exist?(filename)
    abort("rake aborted!") if ask("#{filename} already exists. Do you want to overwrite?", ['y', 'n']) == 'n'
  end
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "layout: post"
    post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
    post.puts "date: #{Time.now.strftime('%Y-%m-%d %H:%M')}"
    post.puts "published: false"
    post.puts "comments: true"
    post.puts "categories: "
    post.puts "---"
  end
  system "subl \"#{filename}\""
end
```

### Post Renaming

During deployment, I wanted published post files to be renamed using the date contained in the file.  This situation occurs because I often start working on a draft post but don't get around to finishing it for several days.  When I do finish it, I set the date in the header of the file to be correct and flip the 'published' flag to 'true'.

The date in the filename doesn't affect anything with how the site is published, but it's nice to have the filename match the actual post date.  I accomplished this by creating a new rake task to systematically rename any files in ./source/_posts which have a filename inconsistent with the date inside the file.  I then call `rake rename_posts` in my deployment script so that files get fixed every time I deploy.  Note, draft/unpublished files are ignored by this task.

``` ruby ./Rakefile
desc "Rename files in the posts directory if the filename does not match the post date in the YAML front matter"
task :rename_posts do
  Dir.chdir("#{source_dir}/#{posts_dir}") do
    Dir['*.markdown'].each do |post|
      post_date = ""
      File.open( post ) do |f|
        f.grep( /^date: / ) do |line|
          post_date = line.gsub(/date: /, "").gsub(/\s.*$/, "")
          break
        end
      end
      post_title = post.to_s.gsub(/\d{4}-\d{2}-\d{2}/, "")  # Get the post title from the currently processed post
      new_post_name = post_date + post_title # determing the correct filename
      is_draft = false
      File.open( post ) do |f|
          f.grep( /^published: false/ ) do |line|
            is_draft = true
            break
          end
      end
      if !is_draft && post != new_post_name     
          puts "renaming #{post} to #{new_post_name}"
          FileUtils.mv(post, new_post_name)
      end
    end
  end
end
```

### Rack::Rewrite

Ewal.net has had a lots of different content since I first created it back in the 1990s.  And bizarrely, some people still occasionally come to ancient URLs that have long since ceased to exist.

Also, Ewal.net now contains blog posts about [TrendWeight](/trendweight/) that used to be hosted on a different blog engine which had a different set of permalinks.

To deal with both issues, I use [Rack-Rewrite](https://github.com/jtrupiano/rack-rewrite) as described by Scott Watermasysk in [this blog post](http://www.scottw.com/octopress-customizations).

My rewrite rules handle making sure people looking for old TrendWeight blog posts end up in the right place and that people trying to visit those ancient URLs that seem to most commonly still be used end up some place useful:

``` ruby ./config.ru
require 'rack-rewrite'

# other stuff appears here ...

use Rack::Rewrite do
  r301 %r{^/2012/08/new-feature-1-kg-220462-lb.html}, 'http://www.ewal.net/2012/08/20/new-feature-1-kg-equals-2-dot-20462-lb/', :host => "blog.trendweight.com"
  r301 %r{^/2012/07/fitbit-aria-retina-displays-user.html}, 'http://www.ewal.net/2012/07/09/fitbit-aria-retina-displays-user-interface-improvements/', :host => "blog.trendweight.com"
  r301 %r{^/2012/04/fitbit-aria-support-coming-soon.html}, 'http://www.ewal.net/2012/04/24/fitbit-aria-support-coming-soon/', :host => "blog.trendweight.com"
  r301 %r{^/2012/03/withings-is-having-technical.html}, 'http://www.ewal.net/2012/03/24/withings-is-having-technical-difficulties/', :host => "blog.trendweight.com"
  r301 %r{^/2012/01/withings-is-having-technical.html}, 'http://www.ewal.net/2012/01/19/withings-is-having-technical-difficulties/', :host => "blog.trendweight.com"
  r301 %r{^/2012/01/missed-day-no-problem-linear.html}, 'http://www.ewal.net/2012/01/15/missed-a-day-no-problem/', :host => "blog.trendweight.com"
  r301 %r{^/2011/12/upcoming-maintenance.html}, 'http://www.ewal.net/2011/12/31/upcoming-maintenance/', :host => "blog.trendweight.com"
  r301 %r{^/2011/12/new-feature-explore-past.html}, 'http://www.ewal.net/2011/12/09/new-feature-explore-the-past/', :host => "blog.trendweight.com"
  r301 %r{^/2011/12/better-looking-long-term-charts.html}, 'http://www.ewal.net/2011/12/01/better-looking-long-term-charts/', :host => "blog.trendweight.com"
  r301 %r{^/2011/11/technical-difficulties.html}, 'http://www.ewal.net/2011/11/30/technical-difficulties/', :host => "blog.trendweight.com"
  r301 %r{^/2011/11/new-feature-goal-bands.html}, 'http://www.ewal.net/2011/11/29/new-feature-goal-bands/', :host => "blog.trendweight.com"
  r301 %r{^/2011/11/introducing-trendweight.html}, 'http://www.ewal.net/2011/11/07/introducing-trendweight/', :host => "blog.trendweight.com"
  r301 '/feeds/posts/default', 'http://www.ewal.net/categories/trendweight/atom.xml', :host => "blog.trendweight.com"
  r301 %r{.*}, 'http://www.ewal.net/trendweight/', :host => "blog.trendweight.com"
  r301 %r{^/shazam.php}, 'https://sourceforge.net/projects/hmdj/'
  r301 %r{^/hmdj-docs}, 'https://sourceforge.net/projects/hmdj/'
  r301 %r{^/_shazam.aspx}, 'https://sourceforge.net/projects/hmdj/'
  r301 %r{^/hmdj/}, 'https://sourceforge.net/projects/hmdj/'
  r301 %r{^/PermaLink,guid,f314a8bc-4a97-4a77-b2de-c2771b77f222.aspx}, 'http://www.iis.net/download/urlrewrite'
end

# other stuff appears here ...

```

### 404 Errors

Because I didn't set up rewrite rules for every single URL that has ever been valid on Ewal.net, I wanted to make sure that there were appropriate 404 errors for pages that don't exist.  By default, Octopress has a 404 page that tells humans that a page they requested doesn't exist.  However, if you look at the actual HTTP traffic, you'll see that that page is returned with an HTTP 200 status.  This is a problem because it means that Google and other search engines that are following links will think these URLs are actual pages (that happen to have pointless content).  Besides cluttering up Google's index, that is also bad for my site ranking (which isn't that great to begin with and can't afford any dings against it) because Google will see lots of URLs with exactly the same content which they consider to be search engine spam.

The solution is to make Sinatra (the super lightweight ruby web application engine that serves up the static octopress files) return an actual 404 for these pages.  This requires using the (currently) unreleased version of Sinatra from GitHub because the feature we need isn't in the currently released version.  This isn't too hard to accomplish.  I replaced the existing Sinatra line in my Gemfile with the line below and then ran `bundle update` to update the installed gems.

    gem 'sinatra', :git => "git://github.com/sinatra/sinatra.git"

Then, in config.ru, I updated the Sinatra code to return a 404 status for URLs that don't exist (line 8 below):

``` ruby ./config.ru
class SinatraStaticServer < Sinatra::Base  

  get(/.+/) do
    send_sinatra_file(request.path) {404}
  end

  not_found do
    send_file(File.join(File.dirname(__FILE__), 'public', '404.html'), {:status => 404})
  end

  def send_sinatra_file(path, &missing_file_block)
    file_path = File.join(File.dirname(__FILE__), 'public',  path)
    file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i  
    File.exist?(file_path) ? send_file(file_path) : missing_file_block.call
  end

end
```




### Ping Services

I added several rake tasks that notify search engines and blog ping services about new content (inspired by [this gist](https://gist.github.com/1709714)).  I call these with `rake notify` after I deploy new content.

``` ruby ./Rakefile
desc 'Ping pingomatic'
task :pingomatic do
  begin
    require 'xmlrpc/client'
    puts '* Pinging ping-o-matic'
    XMLRPC::Client.new('rpc.pingomatic.com', '/').call('weblogUpdates.extendedPing', 'Ewal.net' , 'http://www.ewal.net', 'http://www.ewal.net/atom.xml')
  rescue LoadError
    puts '! Could not ping ping-o-matic, because XMLRPC::Client could not be found.'
  end
end

desc 'Notify Google of the new sitemap'
task :sitemapgoogle do
  begin
    require 'net/http'
    require 'uri'
    puts '* Pinging Google about our sitemap'
    Net::HTTP.get('www.google.com', '/webmasters/tools/ping?sitemap=' + URI.escape('http://www.ewal.net/sitemap.xml'))
  rescue LoadError
    puts '! Could not ping Google about our sitemap, because Net::HTTP or URI could not be found.'
  end
end

desc 'Notify Bing of the new sitemap'
task :sitemapbing do
  begin
    require 'net/http'
    require 'uri'
    puts '* Pinging Bing about our sitemap'
    Net::HTTP.get('www.bing.com', '/webmaster/ping.aspx?siteMap=' + URI.escape('http://www.ewal.net/sitemap.xml'))
  rescue LoadError
    puts '! Could not ping Bing about our sitemap, because Net::HTTP or URI could not be found.'
  end
end

desc "Notify various services about new content"
task :notify => [:pingomatic, :sitemapgoogle, :sitemapbing] do
end
```

### Heroku Deployment

Last but not least, although I have been experimenting with [Octopress on Azure](/2012/08/28/octopress-plus-windows-azure-web-sites/), I currently host this site on [Heroku](http://www.heroku.com/).  I don't use the deployment method discussed in the Octopress documentation, though.  Mostly because I don't want to have the generated files in ./public/ included in my git repository.  I use a modified version of the method described by [Joshua Wood](http://joshuawood.net/how-to-deploy-jekyll-slash-octopress-to-heroku/).

My minimal Heroku Gemfile has both Sinatra and Rake-Rewrite:

``` ruby ./_heroku/Gemfile
source "http://rubygems.org"

gem 'sinatra', :git => "git://github.com/sinatra/sinatra.git"
gem 'rack-rewrite'
```

I have a slightly modified rake task which copies my config.ru file to the _heroku folder every time I deploy (line 5 below) in case I have added a new rewrite rule, etc:

``` ruby ./Rakefile
desc "deploy basic rack app to heroku"
multitask :heroku do
  puts "## Deploying to Heroku "
  (Dir["#{deploy_dir}/public/*"]).each { |f| rm_rf(f) }
  system "cp config.ru #{deploy_dir}/"
  system "cp -R #{public_dir}/* #{deploy_dir}/public"
  puts "\n## copying #{public_dir} to #{deploy_dir}/public"
  cd "#{deploy_dir}" do
    system "git add ."
    system "git add -u"
    puts "\n## Committing: Site updated at #{Time.now.utc}"
    message = "Site updated at #{Time.now.utc}"
    system "git commit -m '#{message}'"
    puts "\n## Pushing generated #{deploy_dir} website"
    system "git push heroku #{deploy_branch}"
    puts "\n## Heroku deploy complete"
  end
end
```

Everything else is as described in [Joshua's Post](http://joshuawood.net/how-to-deploy-jekyll-slash-octopress-to-heroku/).  To deploy, I run these commands (usually via a shell script):

    rake rename_posts
    rake generate
    rake deploy
    rake notify

