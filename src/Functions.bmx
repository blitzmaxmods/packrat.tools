
'	FUNCTIONS FOR MANUALLY CREATING PATTERNS

Const CASE_SENSITIVE:Int = True
Const CASE_INSENSITIVE:Int = False

' AND PREDICATE / AND LOOKAHEAD
Function ANDPRED:TPattern( pattern:TPattern )	', name:String="" )
	Return New TAndPredicate( pattern )
'	Return New TAndPredicate( pattern, name )
End Function

Function ANY:TPattern()
	Return New TAny()
End Function

Function CAPTURE:TPattern( pattern:TPattern )
	Return New TCapture( pattern )
End Function
Function CAPTURE:TPattern( name:String, pattern:TPattern )
	Return New TCapture( pattern, name )
End Function

Function CHARSET:TPattern( charset:String )
	Return New TCharset( charset )
End Function
'Function CHARSET:TPattern( name:String, charset:String )
'	Return New TCharset( charset, name )
'End Function
Function CHARSET:TPattern( charset:String[] )
	Return New TCharset( charset )
End Function
'Function CHARSET:TPattern( name:String, charset:String[] )
'	Return New TCharset( charset, name )
'End Function

'Function CHOICE:TPattern( name:String, pattern:TPattern[] )
'	Return New TChoice( pattern, name )
'End Function
Function CHOICE:TPattern( pattern:TPattern[] )
	Return New TChoice( pattern )
End Function

'Function choice:TPattern( kind:Int, pattern:TPattern[] )
'	Return New TChoice( pattern, kind )
'End Function

'Function choice:TPattern( pattern:TPattern[] )
'	Return New TChoice( pattern )
'End Function

Function ERROR:TPattern( pattern:TPattern )	', message:String )
	Return New TError( pattern )	', message )
End Function

' Expect records "Furthest point" information that is used
' When the next ERROR statement is processed
Function expect:TPattern( pattern:TPattern )	', error:String )
	Return New TExpect( pattern )
End Function

Function GROUP:TPattern( pattern:TPattern = Null )
	Return New TGroup( pattern )
End Function
'Function GROUP:TPattern( name:String, pattern:TPattern = Null )
'	Return New TGroup( pattern, name )
'End Function

' A Keyword is a case insensitive literal
Function KEYWORD:TPattern( Text:String )
	'DebugStop
	Local words:String[] = Text.split( " " )
	If Len(words)=1; Return New TLiteral( Text, CASE_INSENSITIVE )
	'
	'DebugStop
	Local pattern:TPattern[]
	For Local index:Int = 0 Until words.Length
		pattern :+ [ SYMBOL(Chr(32)), New TLiteral( words[index], CASE_INSENSITIVE ) ]
	Next
	Return sequence( pattern[1..] )
End Function

Function LITERAL:TPattern( pattern:String )
	Return New TLiteral( pattern, CASE_SENSITIVE )	', iffail )
End Function
Function LITERAL:TPattern( pattern:String, casesensitive:Int )	', iffail:String="" )
	Return New TLiteral( pattern, casesensitive )
End Function
'Function LITERAL:TPattern( name:String, pattern:String, casesensitive:Int )	', iffail:String="" )
'	Return New TLiteral( pattern, name, casesensitive )
'End Function

Function NONTERMINAL:TPattern( grammar:TGrammar, name:String )
	Return New TNonTerminal( name, grammar )
End Function

'Function NAMED:TPattern( name:String, pattern:TPattern )
'	pattern.name = name
'	Return pattern
'End Function

' Negative lookahead
'Function NOTPRED:TPattern( name:String, pattern:TPattern )
'	Return New TNotPredicate( pattern, name )
'End Function
Function NOTPRED:TPattern( pattern:TPattern )
	Return New TNotPredicate( pattern )
End Function

Function ONEORMORE:TPattern( pattern:TPattern )
	Return New TOneOrMore( pattern )
End Function
'Function ONEORMORE:TPattern( name:String, pattern:TPattern )
'	Return New TOneOrMore( pattern, name )
'End Function

' OPTIONAL PATTERN (Zero or One)
Function OPTIONAL:TPattern( pattern:TPattern )
	Return New TOptional( pattern )
End Function
'Function OPTIONAL:TPattern( name:String, pattern:TPattern )
'	Return New TOptional( pattern, name )
'End Function

' Create a range
'Function RANGE:TPattern( name:String, range:String )
'	Return New TRange( range )
'End Function
Function RANGE:TPattern( range:String )
	Return New TRange( range )
End Function

' Read characters until pattern found
'Function READUNTIL:TPattern( name:String, pattern:TPattern )
'	Return New TSequence([ ZEROORMORE( SEQUENCE([ NOTPRED(pattern), ANY() ]) ), pattern ], name)
'End Function
Function READUNTIL:TPattern( pattern:TPattern )
	Return New TSequence([ ZEROORMORE( SEQUENCE([ NOTPRED(pattern), ANY() ]) ), pattern ] )
End Function

' Read characters until end of line or end of input
'TODO: Add optimised reader here
Function RECOVERLINE:TPattern()
	Local SP:TPattern      = SYMBOL( $20 )
	Local HTAB:TPattern    = SYMBOL( $09 ) 
	Local CR:TPattern      = SYMBOL( $0D )
	Local LF:TPattern      = SYMBOL( $0A )	
	Local _:TPattern       = ZEROORMORE( CHOICE([ SP, HTAB ]) )
	Local EOI:TPattern     = NOTPRED( ANY() )		                    ' EOI <- !.
	Local EOL:TPattern     = SEQUENCE([ _, OPTIONAL( CR ), LF ])		' EOL <- ( _ CR? LF ) 
	Local pattern:TPattern = CHOICE([EOL, EOI])
	Return New TSequence([ ZEROORMORE( SEQUENCE([ NOTPRED(pattern), ANY() ]) ), pattern ] )
End Function

'Function SEQUENCE:TPattern( name:String, pattern:TPattern[] )
'	Return New TSequence( pattern, name )
'End Function
Function SEQUENCE:TPattern( pattern:TPattern[] )
	Return New TSequence( pattern )
End Function

Function SYMBOL:TPattern( character:String )
	Return New TSymbol( character )
End Function
Function SYMBOL:TPattern( character:Int )
	Return New TSymbol( character )
End Function

'Function sequence:TPattern( pattern:TPattern[], kind:Int=KIND_SEQUENCE, iffail:String="" )
'	Return New TSequence( pattern, kind, iffail )
'End Function

Function ZEROORMORE:TPattern( pattern:TPattern )
	Return New TZeroOrMore( pattern )
End Function
'Function ZEROORMORE:TPattern( name:String, pattern:TPattern )
'	Return New TZeroOrMore( pattern, name )
'End Function

' PRE-DEFINED CORE RULES

' Based on rfc5234 ABNF definitions
'Global ALPHA:TPattern     = RANGE(   "ALPHA",    "A-Za-z" )               ' Case insensitive     A..Z, a..z
'Global CHAR:TPattern      = RANGE(   "CHAR",     Chr($20)+"-"+Chr($7E) )  ' 7 BIt ASCII except CTRL
'Global CR:TPattern        = CHARSET( "CR",       Chr($0D) )               ' Carriage Return      \n
'Global CRLF:TPattern      = CHARSET( "CRLF",     Chr($0D)+Chr($0A) )      ' Newline (Windows)    \n\r
'Global DIGIT:TPattern     = RANGE(   "DIGIT",    "0-9" )                  ' Digit 0 to 9        0123456789
'Global DQUOTE:TPattern    = CHARSET( "DQUOTE",   Chr($22) )               ' Double Quote         "
'Global HEXDIGIT:TPattern  = RANGE(   "HEXDIGIT", "0-9A-Fa-f" )            ' Hexadecimal digits
'Global HTAB:TPattern      = CHARSET( "HTAB",     Chr($09) )               ' Horizontal Tab       \t
'Global LF:TPattern        = CHARSET( "LF",       Chr($0A) )               ' Line Feed            \r
'Global OCTET:TPattern     = RANGE(   "OCTET",    Chr($00)+"-"+Chr($FF) )  ' Any 8 bit character
'Global SP:TPattern        = CHARSET( "SP",       Chr($20) )               ' Space
'Global VCHAR:TPattern     = RANGE(   "VCHAR",    Chr($21)+"-"+Chr($7E) )  ' visible (printing) characters

'Global WSP:TPattern       = ONEORMORE( "WSP",    choice([SP,HTAB]) )      ' Whitespace

