# JumpStart Georgia's StoryBuilder used for [Chai Khana's site](http://chai-khana.org).

## Summary
StoryBuilder is a web application that allows users to build mixed-media stories that can then be shared with the world. You can try StoryBuilder out for yourself [here](http://storybuilder.jumpstart.ge/en).

The idea for this application came after viewing mixed-media stories like this [New York Times story](http://www.nytimes.com/newsgraphics/2013/10/27/south-china-sea/). We wanted to be able to create stories like this without having to start from scratch for every story.  We wanted to be able to quickly put interactive, mixed-media stories together without having to require a lot of designer or developer time.  That is the goal of this application.


## How It Works
StoryBuilder is similar to a blog editor like wordpress or tumblr, but at this point is still a little rustic.  In essence, StoryBuilder allows you to add content, images, and/or videos into sections in a story that can be ordered however you want.

Right now there are four types of sections that can be created: 
* Text: Simple text with a rich-text editor like Word or Google Docs.
* Embed Online Media: Add online video and audio from sites like youtube, vimeo and soundcloud.
* Full-Screen Media: This can be a combination of images and/or videos that will appear on the screen in a vertical slider format, one after the other.  The media is stretched to fill the users entire window and a small caption text can appear ontop of the media.
* Image Slideshow: Images in a simple horizontal slideshow.

Aside from building the story, you also have the ability to:
* clone a story as the beginning of a new story
* download a story so you can host it on any website
* embed a pretty link to the story
* embed the full story
* invite others to help collaborate on the story
* share a private URL to allow others to review your story before it is published


## Dependencies
You will need to install the following programs:
* imagemagick - to process the uploaded images and create all of the different sizes required
* ffmpeg - to process video into a format suitable for use in an HTML5 video tag ([install instructions here](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu))
* exiftool - to check if video has audio (install with: sudo apt-get install libimage-exiftool-perl)
* cron jobs - to send notifications and to process videos

You will need the following [Environment Variables](https://help.ubuntu.com/community/EnvironmentVariables) set:
* STORY_BUILDER_FROM_EMAIL - email address to send all emails from
* STORY_BUILDER_FROM_PWD - password of above email address
* STORY_BUILDER_TO_EMAIL - email address to send feedback form messages to
* STORY_BUILDER_ERROR_TO_EMAIL - email address to send application errors to
* STORY_BUILDER_FACEBOOK_APP_ID - Facebook is one of the options for logging in to the system and you must have an app account created under facebook developers. This key stores the application id.
* STORY_BUILDER_FACEBOOK_APP_SECRET - This key stores the facebook application secret.
* STORY_BUILDER_DISQUS - Disqus is used for the commenting system and your unique website key is stored here
* STORY_BUILDER_BITLY_TOKEN - bit.ly generic access token ([get from here](https://bitly.com/a/oauth_apps)) used to shorten URLs to published stories
* STORY_BUILDER_BITLY_TOKEN_DEV - same as above, but for use in testing environments
* STORY_BUILDER_ADDTHIS_PROFILEID - addthis.com profile ID ([get from here](https://www.addthis.com/settings/publisher)) to use the addthis share tools
* STORY_BUILDER_ADDTHIS_PROFILEID_DEV - same as above, but for use in testing environments
* STORY_BUILDER_YOUTUBE_API_KEY - YouTube API key ([get from here](https://console.developers.google.com/project)) is used to verify that the YouTube urls exist.
* DETECT_LANGUAGE_API_KEY - [Language Detection API](http://detectlanguage.com/) key for determining the language a story is written in

