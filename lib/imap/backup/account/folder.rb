# encoding: utf-8
require 'forwardable'

module Imap::Backup
  module Account; end

  class Account::Folder
    extend Forwardable

    REQUESTED_ATTRIBUTES = ['RFC822', 'FLAGS', 'INTERNALDATE']

    attr_reader :connection
    attr_reader :folder

    delegate imap: :connection

    def initialize(connection, folder)
      @connection, @folder = connection, folder
    end

    def uids
      imap.examine(folder)
      imap.uid_search(['ALL']).sort.map(&:to_s)
    rescue Net::IMAP::NoResponseError => e
      Imap::Backup.logger.warn "Folder '#{folder}' does not exist"
      []
    end

    def fetch(uid)
      imap.examine(folder)
      message = imap.uid_fetch([uid.to_i], REQUESTED_ATTRIBUTES)[0][1]
      message['RFC822'].force_encoding('utf-8') if RUBY_VERSION > '1.9'
      message
    rescue Net::IMAP::NoResponseError => e
      Imap::Backup.logger.warn "Folder '#{folder}' does not exist"
      nil
    end
  end
end
