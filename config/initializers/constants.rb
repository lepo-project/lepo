# Global constants for LePo Application

# LePo specific constants begin here
# site name shown at title bar and signin page
SITE_NAME = 'LePo'.freeze

# set true for https
SSL_ACCESS = false

# IP addresses that system manager can singnin
SYSTEM_MANAGE_IPS = ['127.0.0.1'].freeze

# max size[MB]/file for user, course and assignment profile image file
IMAGE_MAX_FILE_SIZE = 3

# character length for folder name of file upload
FOLDER_NAME_LENGTH = 32

# min and max character length for user password
USER_PASSWORD_MIN_LENGTH = 6
USER_PASSWORD_MAX_LENGTH = 14

# character length for user token
USER_TOKEN_LENGTH = 20

# max character length for user text form
USER_TEXT_LENGTH = 800

# max size of links per user: just to prevent abuse
USER_LINK_MAX_SIZE = 30

# max size[MB]/file for content page, asset and attachment file
CONTENT_MAX_FILE_SIZE = 80

# max objective number per content: should not larger than 5
CONTENT_OBJECTIVE_MAX_SIZE = 3

# max goal number per course
COURSE_GOAL_MAX_SIZE = 5

# max group number per course
COURSE_GROUP_MAX_SIZE = 9

# max lesson number per course
COURSE_LESSON_MAX_SIZE = 99

# initial setting for lesson status: draft / open
LESSON_STATUS_DEFAULT = 'open'.freeze

# max size[MB]/file for assignment outcome file
OUTCOME_MAX_FILE_SIZE = 10

# max number for assignment outcome file per assignment
OUTCOME_MAX_SIZE = 9

# max number of user search results for system administrator
USER_SEARCH_MAX_SIZE = 50

# max peer review number per learner
NOTE_PEER_REVIEW_MAX_SIZE = 9

# time delay for autocomplete
AUTOCOMPLETE_DELAY = 100

# max autocomplete number
AUTOCOMPLETE_MAX_SIZE = 20

# min character length for autocomplete
AUTOCOMPLETE_MIN_LENGTH = 1

# autocomplete name category: signin / signin_full / signin_full_phonetic
AUTOCOMPLETE_NAME_CATEGORY = 'signin_full_phonetic'.freeze

# FIXME: PushNotification
# FCM_AUTHORIZATION_KEY = ''
