# JumpStart Georgia's Story Builder

## Summary
Story Builder is a web application that allows users to build mixed-media stories that can then be shared with the world. You can try Story Builder out for yourself on our [test site](http://dev-storybuilder.jumpstart.ge/en).

The idea for this application came after viewing this [New York Times story](http://www.nytimes.com/newsgraphics/2013/10/27/south-china-sea/). We wanted to be able to create stories like this without having to start from scratch for every story.  We wanted to be able to quickly put interactive, mixed-media stories together without having to require a lot of designer or developer time.  That is the goal of this application.


## How It Works
Story Builder is similar to a blog editor like wordpress or tumblr, but at this point is still a little rustic.  In essence, Story Builder allows you to add content, images, and/or videos into sections in a story that can be ordered however you want.

Right now there are two types of sections that can be created: Content and Full-Screen Media.
* Content: Simple text with a rich-text editor like Word of Google Docs.
* Full-Screen Media: This can be a combination of images and/or videos that will appear on the screen in a vertical slider format, one after the other.  The media is stretched to fill the users entire window and a small caption text can appear ontop of the media.

Aside from entering the story into the sections, you also have the ability to:
* re-arrange the sections in the story
* clone a story as the beginning of a new story
* export a story so you can host it on any website

## Dependencies
You will need to install the following programs:
* ffmpeg - to create image from video (image is shown instead of video on mobile devices)
* imagemagick - to process the images upload and create all of the different sizes required

You will need the following Environment Variables set:
* STORY_BUILDER_DISQUS - Disqus is used for the commenting system and your unique website it is stored here
* STORY_BUILDER_FACEBOOK_APP_ID - Facebook is one of the options for logging in to the system and you must have an app account created under facebook developers. This key stores the application id.
* STORY_BUILDER_FACEBOOK_APP_SECRET - This key stores the application secret.
* STORY_BUILDER_BITLY_TOKEN - bit.ly generic access token (get from here: https://bitly.com/a/oauth_apps) used to shorten URLs to published stories
* STORY_BUILDER_BITLY_TOKEN_DEV - same as above, but for use in testing environments
* STORY_BUILDER_ADDTHIS_PROFILEID - addthis.com profile ID (get from here: https://www.addthis.com/settings/publisher) to use the addthis share tools
* STORY_BUILDER_ADDTHIS_PROFILEID_DEV - same as above, but for use in testing environments
* STORY_BUILDER_FROM_EMAIL - email address to send feedback all emails from
* STORY_BUILDER_FROM_PWD - password of above email address
* STORY_BUILDER_TO_EMAIL - email address to send feedback form messages to
* STORY_BUILDER_ERROR_TO_EMAIL - email address to send application errors to



## To Do List
### Short Term Tasks
* create a more wizard like process for building the story
* add ability to drag and drop section for re-arranging
* users can create groups and have their own page to show their published works
* add ability to create one story in multiple languages
* ability to log in with something other than facebook

### Long Term Tasks
* store the media on Amazon S3 cloud
* have multiple themes to select from
* be able to edit colors, fonts, etc
* select from different transitions between sections
* add ability to include interactive maps
* add ability to include charts
* add ability to include data tables


## Version History
### 1.0
Most of the focus was spent on the experience of finding and reading stories. Some time was spent on the form for building the stories, but a complete overhaul of this system is needed and will be the focus of our next major release.
* applied much nicer theme to the site
* added story read counter
* added share links
* added comments
* added like button
* can embed stories in two formats: a pretty link or the full story
* can customize url to story
* can search, filter and sort published stories on home page
* can write summary of story (this is used on home page and when sharing in facebook)
* added ability to indicate what language your story is in (allows users to filter on home page)
* added categories to stories
* added tags to stories
* each user has their own page to show their published works
* can customize url to user page
* can write summary about self and this appears on your user page
* added ability to include online videos (embed youtube, vimeo, etc)
* can invite other users to be a collaborator on your story
* added notification system to alert you when new stories are published, your story is selected as a staff pick, comments are made, etc
* can indicate which notifications you wish to receive
* allow users to follow other users and receive notifications when new stories are published
* added RSS feed of all published stories


### 0.4
* added horizontal image gallery section
* added help text to forms
* translated site completely into Georgian
* moved all media files (images, videos, audio) into one table
* started process for having multiple templates - right now only one template exists

### 0.3
* create a more appealing landing page
* applied user authorization
* ability to clone a story so it can be used as the start of a new story
* ability to export a story so it can be hosted on any website
* can assign users to edit your story

## License
TBD
