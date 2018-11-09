# Global constants for LePo

# ===== System constatns =====
# system name shown at title bar and signin page
SYSTEM_NAME = 'LePo'.freeze

# flag for use of ssl
SYSTEM_SSL_FLAG = false

# IP addresses that system staffs can singnin
SYSTEM_STAFF_SIGNIN_IP = ['127.0.0.1'].freeze

# Log file when using IMS OneRoster API
SYSTEM_ROSTER_LOG_FILE = 'log/roster.log'

# ===== Versatile constatns =====
# time delay for autocomplete
AUTOCOMPLETE_DELAY = 100

# max autocomplete number
AUTOCOMPLETE_MAX_SIZE = 20

# min character length for autocomplete
AUTOCOMPLETE_MIN_LENGTH = 1

# character length for folder name of file upload
FOLDER_NAME_LENGTH = 32

# max size[MB]/file for user, course and assignment profile image file
IMAGE_MAX_FILE_SIZE = 3

# ===== Model related constatns =====
# max size of bookmarks per user: just to prevent abuse
BOOKMARK_MAX_SIZE = 30

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

# max length of course manager display
COURSE_MANAGER_DISPLAY_MAX_LENGTH = 16

# max period number for course
COURSE_PERIOD_MAX_SIZE = 7

# max number of course search results for system administrator
COURSE_SEARCH_MAX_SIZE = 50

# initial setting for lesson status: draft / open
LESSON_STATUS_DEFAULT = 'open'.freeze

# max character length for note overview
NOTE_OVERVIEW_MAX_LENGTH = 500

# max peer review number per learner
NOTE_PEER_REVIEW_MAX_SIZE = 9

# max size[MB]/file for assignment outcome file
OUTCOME_MAX_FILE_SIZE = 10

# max number for assignment outcome file per assignment
OUTCOME_MAX_SIZE = 9

# max character length for snippet
SNIPPET_MAX_LENGTH = 800

# min and max character length for user password
USER_PASSWORD_MIN_LENGTH = 6
USER_PASSWORD_MAX_LENGTH = 14

# flag for use of phonetic_family_name and phonetic_given_name
USER_PHONETIC_NAME_FLAG = true

# max number of user search results for system administrator
USER_SEARCH_MAX_SIZE = 50

# character length for user token
USER_TOKEN_LENGTH = 20

# max character length for web snippet (less or equal to SNIPPET_MAX_LENGTH)
WEB_SNIPPET_MAX_LENGTH = 300

# max character length for web open snippet (less or equal to WEB_SNIPPET_MAX_LENGTH)
WEB_OPEN_SNIPPET_MAX_LENGTH = 50
