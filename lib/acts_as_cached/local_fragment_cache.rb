module ActsAsCached
  module LocalFragmentCache
    @@local_fragment_cache = {}
    mattr_accessor :local_fragment_cache

    def read_with_local_cache(*args) 
      @@local_fragment_cache[args.first] ||= read_without_local_cache(*args)
    end

    def self.add_to(klass)
      return if klass.ancestors.include? self
      klass.send :include, self

      klass.class_eval do
        %w( read ).each do |target|
          alias_method_chain target, :local_cache
        end
      end
    end
    
    module InstanceMethods
      # cache fu extension to be used around blocks that should only be executed when no cache exists
      def when_fragment_expired(key, unused_param = nil, &block)
        puts '@@@@@@@@@@@@@@@@ Update your code! Don\' pass times to this method [key: #{key}]' if unused_param
        unless read_fragment(key)
          yield
        end
      end
    
    end
  end
end

module ActionController
  class Base
    
    include ActsAsCached::LocalFragmentCache::InstanceMethods    
    
    def local_fragment_cache_for_request
      ActsAsCached::LocalFragmentCache.add_to ActsAsCached::FragmentCache::Extensions 
      ActsAsCached::LocalFragmentCache.local_fragment_cache = {}
    end
    
  end
end 
