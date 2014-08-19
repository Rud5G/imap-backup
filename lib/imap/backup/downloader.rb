# encoding: utf-8
require 'imap/backup/worker_base'

module Imap::Backup
  class Downloader < WorkerBase
    def run
      uids = folder.uids - serializer.uids
      Imap::Backup.logger.debug "New messages: #{uids.count}"
      uids.each do |uid|
        message = folder.fetch(uid)
        next if message.nil?
        serializer.save(uid, message)
      end
    end
  end
end
