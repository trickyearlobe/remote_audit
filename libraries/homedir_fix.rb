# Inspec requires the user's HOME environment variable to be set
# This may not happen if Inspec is run by Chef Client under SystemD
# See https://github.com/inspec/inspec/pull/5317 which will render this fix obsolete

# Make sure that HOME is set if it's missing
ENV['HOME'] ||= Etc.getpwuid.dir
