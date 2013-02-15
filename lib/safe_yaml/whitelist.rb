module SafeYAML
  class Whitelist
    def initialize
      reset!
    end

    def check(tag, value)
      @allowed.each do |ok, checker|
        if ok === tag
          if checker == true
            return :cacheable
          elsif checker.call(value)
            return :allowed
          end
        end
      end
      nil
    end

    def reset!
      @allowed = {}
      if SafeYAML::YAML_ENGINE == "psych"
        # psych doesn't tag the default types, except for binary
        add("!binary",
            "tag:yaml.org,2002:binary")
      else
        add("tag:yaml.org,2002:str",
            "tag:yaml.org,2002:int",
            "tag:yaml.org,2002:float",
            "tag:yaml.org,2002:binary",
            "tag:yaml.org,2002:merge",
            "tag:yaml.org,2002:null",
            %r{^tag:yaml.org,2002:bool#},
            %r{^tag:yaml.org,2002:float#},
            %r{^tag:yaml.org,2002:timestamp#},
            "tag:ruby.yaml.org,2002:object:YAML::Syck::BadAlias")
      end
    end

    def add(*tags, &block)
      tags.each do |tag|
        @allowed[tag] = block || true
      end
    end

    def remove(*tags)
      tags.each { |tag| @allowed.delete(tag) }
    end
  end
end
