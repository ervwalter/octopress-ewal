require 'bundler/setup'
require 'sinatra/base'
require 'rack-rewrite'

# The project root directory
$root = ::File.dirname(__FILE__)

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

run SinatraStaticServer