#!/usr/bin/ruby
module Enumberable

  def my_each
    return to_enum(:my_each) unless block_given?
    n = 0
    while n < self.size
      yield(self[n])                if self.is_a?(Array)
      yield(keys[n], self[keys[n]]) if self.is_a?(Hash)
      yield([to_a[n]])              if self.is_a?(Range)
      n += 1
    end
    self
  end

  def my_each_with_index
    return to_enum(:my_each_with_index) unless block_given?
    n = 0
    index = 0
    while n < self.size 
      yield(self[n], index)         if self.is_a?(Array)
      yield(keys[n], self[keys[n]]) if self.is_a?(Hash)
      yield(to_a[n], index)         if self.is_a?(Range)
      n += 1
      index += 1
    end
    self
  end

  def my_select
    return to_enum(:my_select) unless block_given?
    if self.is_a?(Array)
      result = []
      my_each { |item| result << item if yield(item) }
    else #if working on a Hash
      result = {} 
      my_each { |key, value| result[key] = value if yield(key, value) }
    end
    result
  end

  def my_all?(pattern = nil) #not working on ranges or hashes
    result = []
    pattern_proc = Proc.new do
      my_each { |item| result << item if pattern === item } 
      result == self ? true : false #if array doesn't match self, not all the items meet the criteria
    end
    if pattern #check first for pattern
      if block_given? #pattern and block given
        STDERR.puts "warning: given block not used"
        pattern_proc.call
      else #just a pattern given
        pattern_proc.call
      end
    elsif block_given?
      my_each { |item| result << item if yield(item) }
      result == self ? true : false
    else
      self.include?(nil) || self.include?(false) ? false : true
    end
  end

  def my_any? (pattern = nil) #not working with ranges(only works with integer ranges) or hashes
    result = []
    pattern_proc = Proc.new do  #proc to apply if a pattern is given
      my_each { |item| result << item if pattern === item }
      result.empty? ? false : true #if array is empty that means nothing returned true, therefore nothing matches criteria
    end
    if pattern #check first for pattern
      if block_given? #pattern and block given
        STDERR.puts "warning: given block not used"
        pattern_proc.call
      else #just a pattern given
        pattern_proc.call
      end
    elsif block_given?
      my_each { |item| result << item if yield(item) }
      result.empty? ? false : true
    else
      return false if self.empty?
      my_each { |item| result << item if item }
      result.empty? ? false : true # result will be empty if all values are nil or false, therefore my_any? returns false
    end
  end

  def my_none? (pattern = nil) #opposite of my_any? #not working with ranges(only works with integer ranges) or hashes
    result = []
    pattern_proc = Proc.new do
      my_each { |item| result << item if pattern === item }
      result.empty? ? true : false
    end
    if pattern #check first for pattern
      if block_given? #pattern and block given
        STDERR.puts "warning: given block not used"
        pattern_proc.call
      else #just a pattern given
        pattern_proc.call
      end
    elsif block_given?
      my_each { |item| result << item if yield(item) }
      result.empty? ? true : false
    else
      return true if self.empty?
      my_each { |item| result << item if item }
      result.empty? ? true : false
    end
  end

  def my_count(argument = nil) #fails with string ranges
    result = []
    count = 0
    counter = Proc.new { |item, index| count = index + 1 }
    if argument
      my_each { |item| result << item if argument == item }
      result.my_each_with_index(&counter)
    elsif block_given?
      my_each { |item| result << item if yield(item) }
      result.my_each_with_index(&counter)
    else
      my_each_with_index(&counter)  
    end
    self.is_a?(Hash) ? count - 2 : count
  end

  def my_map(procedure = nil)
    return to_enum(:my_map) unless block_given?
    result = [] #prevent from mutating original array
    if procedure
      my_each { |item| result << procedure.call(item) } #push items modified by proc into result
    else
      my_each { |item| result << yield(item) } #use block if no proc given
    end
    result
  end
  
  def my_map! #mutates original array
    return to_enum(:my_map!) unless block_given?
    my_each_with_index { |item, index| self[index] = yield(item) }
  end
    
  def my_reduce(starting_value = nil)
    if starting_value == nil
      accumulator = self.to_a[0] #to_a so it works on ranges
      index = 1
    else
      accumulator = starting_value
      index = 0
    end
    while index < self.size
      accumulator = yield(accumulator, self.to_a[index]) #start reducing at first and second values
      index += 1
    end
    accumulator
  end
end 

def multiply_els(array) #testing my_reduce
  array.my_reduce { |item, next_item| item * next_item }
end

include Enumberable