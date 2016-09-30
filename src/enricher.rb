def pair c, p
  {:consume => c, :produce => p}
end

def consume_produce opcode
  case opcode
  when "STOP"
    pair 0, 0
  when "ADD"
    pair 2, 1
  when "SUB"
    return pair 2, 1
  when "MUL"
    return pair 2, 1
  when "DIV"
    return pair 2, 1
  when "SDIV"
    return pair 2, 1
  when "MOD"
    return pair 2, 1
  when "SMOD"
    return pair 2, 1
  when "ADDMOD"
    return pair 3, 1
  when "MULMOD"
    return pair 3, 1
  when "EXP"
    return pair 2, 1
  when "SIGNEXTEND"
    return pair 2, 1
  when "LT"
    return pair 2, 1
  when "GT"
    return pair 2, 1
  when "SLT"
    return pair 2, 1
  when "SGT"
    return pair 2, 1
  when "EQ"
    return pair 2, 1
  when "ISZERO"
    return pair 1, 1
  when "AND"
    return pair 2, 1
  when "OR"
    return pair 2, 1
  when "XOR"
    return pair 2, 1
  when "NOT"
    return pair 1, 1
  when "BYTE"
    return pair 2, 1
  when "SHA3"
    return pair 2, 1
  when "ADDRESS"
    return pair 0, 1
  when "BALANCE"
    return pair 1, 1
  when "ORIGIN"
    return pair 0, 1
  when "CALLER"
    return pair 0, 1
  when "CALLVALUE"
    return pair 0, 1
  when "CALLDATALOAD"
    return pair 1, 1
  when "CALLDATASIZE"
    return pair 0, 1
  when "CALLDATACOPY"
    return pair 3, 0
  when "CODESIZE"
    return pair 0, 1
  when "CODECOPY"
    return pair 3, 0
  when "GASPRICE"
    return pair 0, 1
  when "EXTCODESIZE"
    return pair 1, 1
  when "EXTCODECOPY"
    return pair 4, 0
  when "BLOCKHADH"
    return pair 1, 1
  when "COINBASE"
    return pair 0, 1
  when "TIMESTAMP"
    return pair 0, 1
  when "NUMBER"
    return pair 0, 1
  when "DIFFICULTY"
    return pair 0, 1
  when "GASLIMIT"
    return pair 0, 1
  when "MLOAD"
    return pair 1, 1
  when "MSTORE"
    return pair 2, 0
  when "MSTORE8"
    return pair 2, 0
  when "SLOAD"
    return pair 1, 1
  when "SSTORE"
    return pair 2, 0
  when "JUMP"
    return pair 1, 0
  when "JUMPI"
    return pair 2, 0
  when "PC"
    return pair 0, 1
  when "MSIZE"
    return pair 0, 1
  when "GAS"
    return pair 0, 1
  when "JUMPDEST"
    return pair 0, 0
  when "POP"
    return pair 1, 0
  when /PUSH[1-9]/
    return pair 0, 1
  when /PUSH[1-3][0-9]/
    return pair 0, 1
  when /DUP([0-9]*)/
    arg = $1.to_i
    return pair arg, (arg + 1)
  when /SWAP([0-9]*)/
    arg = $1.to_i
    return pair (arg + 1), (arg + 1)
  when "LOG0"
    return pair 2, 0
  when "LOG1"
    return pair 3, 0
  when "LOG2"
    return pair 4, 0
  when "LOG3"
    return pair 5, 0
  when "LOG4"
    return pair 6, 0
  when "CREATE"
    return pair 3, 1
  when "CALL"
    return pair 7, 1
  when "CALLCODE"
    return pair 7, 1
  when "RETURN"
    return pair 2, 0
  when "DELEGATECALL"
    return pair 6, 1
  when "SUICIDE"
    return pair 1, 0
  else
    fail "unknown optocde #{opcode}"
  end
end

def origin depth, step
  {:depth => depth, :step => step}
end



def update_stack_origins_swap orig, number
  number = number + 1
  new = orig[0...orig.size - number] + [orig[-1]] + orig[orig.size-number+1...orig.size-1] + [orig[orig.size-number]]
  raise "stack lengths do not match #{orig.size} != #{new.size}, #{number}" unless orig.size == new.size
  new
end

def update_stack_origins_dup orig, number
  new = orig + [orig[orig.size-number]]
  raise "stack lengths do not match" unless orig.size + 1 == new.size
  new
end

def update_stack_origins orig, step
  opcode = step["op"]

  if /SWAP([0-9]*)/.match(opcode)
    number = $1.to_i
    return update_stack_origins_swap orig, number
  elsif /DUP([0-9]*)/.match(opcode)
    number = $1.to_i
    return update_stack_origins_dup orig, number
  end

  c = (consume_produce opcode)[:consume]
  p = (consume_produce opcode)[:produce]

  # TODO
  # DUP and SWAP should not just remove n-elements and add m-elements.
  # They should only be touching two elements on the origin

  orig = orig[0...(orig.size-c)]
  here = origin 1, step["step"]
  new_elements = Array.new(p, here)
  orig = orig + new_elements

  orig
end

def modify_structLogs sLogs
  output = []
  step_number = 0
  stack_origins = []

  sLogs.each do |step|
    output << step
    if step["depth"] == 1 then
      step["step"] = step_number
      step_number += 1

      # This assertion should hold in the precondition.
      raise "stack lengths do not match" unless stack_origins.size == step["stack"].size

      c = (consume_produce (step["op"]))[:consume]
      step["arg_origins"] = stack_origins[(stack_origins.size-c)...stack_origins.size]

      stack_origins = update_stack_origins stack_origins, step

    end
  end

  output
end

def modify_input input
  output = {}

  input.each do |k, v|
    if k == 'structLogs'
      output[k] = modify_structLogs v
    else
      output[k] = v
    end
  end

  output
end

require 'optparse'

require 'json'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby rnricher.rb [options] trace.json"

  opts.on("-g", "--graphviz", "produce a graphviz output") do |v|
    options[:dot] = true
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

input_string = ARGF.read
input = JSON.parse(input_string)

output = modify_input input

puts JSON.generate(output, :indent => "	", :object_nl => "\n", :array_nl => "\n")
