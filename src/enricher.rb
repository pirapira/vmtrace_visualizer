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
  end
end

def origin depth, step, nth
  {:depth => depth, :step => step, :nth => nth}
end



require 'json'

input_string = ARGF.read
input = JSON.parse(input_string)

def modify_structLogs sLogs
  sLogs
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

output = modify_input input

puts JSON.generate(output, :indent => "	", :object_nl => "\n", :array_nl => "\n")
