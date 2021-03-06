/*
 * Copyright 2017 Nicola Atzei
 */

package it.unica.tcs.utils

import com.google.inject.Inject
import com.google.inject.Singleton
import it.unica.tcs.bitcoinTM.BooleanType
import it.unica.tcs.bitcoinTM.Expression
import it.unica.tcs.bitcoinTM.Hash160Type
import it.unica.tcs.bitcoinTM.Hash256Type
import it.unica.tcs.bitcoinTM.IntType
import it.unica.tcs.bitcoinTM.KeyType
import it.unica.tcs.bitcoinTM.Network
import it.unica.tcs.bitcoinTM.Parameter
import it.unica.tcs.bitcoinTM.Ripemd160Type
import it.unica.tcs.bitcoinTM.Sha256Type
import it.unica.tcs.bitcoinTM.SignatureType
import it.unica.tcs.bitcoinTM.StringType
import it.unica.tcs.bitcoinTM.TransactionType
import it.unica.tcs.bitcoinTM.Type
import it.unica.tcs.compiler.CompileException
import it.unica.tcs.generator.ExpressionGenerator
import it.unica.tcs.lib.Hash.Hash160
import it.unica.tcs.lib.Hash.Hash256
import it.unica.tcs.lib.Hash.Ripemd160
import it.unica.tcs.lib.Hash.Sha256
import it.unica.tcs.lib.ITransactionBuilder
import java.util.List
import org.bitcoinj.core.DumpedPrivateKey
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2

@Singleton
class CompilerUtils {
	
	@Inject private extension ExpressionGenerator
	
	def String compileActualParams(List<Expression> actualParams) {
		actualParams.map[e|e.compileExpression].join(",")
	}
	
	def String compileFormalParams(List<Parameter> formalParams) {
		formalParams.map[p|p.type.compileType+" "+p.name].join(", ")
    }
	
	def String compileType(Type type) {
    	if(type instanceof IntType) return "Long"
    	if(type instanceof Hash160Type) return "Hash160"
    	if(type instanceof Hash256Type) return "Hash256"
    	if(type instanceof Ripemd160Type) return "Ripemd160"
    	if(type instanceof Sha256Type) return "Sha256"
    	if(type instanceof StringType) return "String"
    	if(type instanceof BooleanType) return "Boolean"
    	if(type instanceof SignatureType) return "byte[]"
    	
    	throw new CompileException("Unexpected type "+type.class.simpleName)
    }
    
    def String compileNetworkParams(EObject obj) {
		val list = EcoreUtil2.getAllContentsOfType(EcoreUtil2.getRootContainer(obj), Network);
			
		if (list.size()==0)	// network undeclared, assume testnet
			return "NetworkParameters.fromID(NetworkParameters.ID_TESTNET)"
			
		if (list.size()==1)
			return if (list.get(0).isTestnet()) 
				   "NetworkParameters.fromID(NetworkParameters.ID_TESTNET)" 
				   else "NetworkParameters.fromID(NetworkParameters.ID_MAINNET)"
			
		throw new IllegalStateException();
	}
    
	def Class<?> convertType(Type type) {
    	if(type instanceof IntType) return Long
    	if(type instanceof StringType) return String
    	if(type instanceof BooleanType) return Boolean
    	if(type instanceof Hash160Type) return Hash160
    	if(type instanceof Hash256Type) return Hash256
    	if(type instanceof Ripemd160Type) return Ripemd160
    	if(type instanceof Sha256Type) return Sha256
		if(type instanceof KeyType) return DumpedPrivateKey
    	if(type instanceof TransactionType) return ITransactionBuilder
    	if(type instanceof SignatureType) return typeof(byte[])
    	
    	throw new CompileException("Unexpected type "+type.class.simpleName)
    }
}
