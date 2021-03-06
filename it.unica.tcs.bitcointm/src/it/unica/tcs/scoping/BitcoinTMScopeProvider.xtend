/*
 * Copyright 2017 Nicola Atzei
 */

/*
 * generated by Xtext 2.11.0
 */
package it.unica.tcs.scoping

import it.unica.tcs.bitcoinTM.Declaration
import it.unica.tcs.bitcoinTM.DeclarationLeft
import it.unica.tcs.bitcoinTM.DeclarationReference
import it.unica.tcs.bitcoinTM.Participant
import it.unica.tcs.bitcoinTM.Receive
import it.unica.tcs.bitcoinTM.Script
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class BitcoinTMScopeProvider extends AbstractDeclarativeScopeProvider {


	def IScope scope_Referrable(DeclarationReference v, EReference ref) {
//		println("Resolving variable: "+v)
		getScopeForParameters(v,
			getScopeForParticipantDeclarations(v, 
				getIScopeForAllContentsOfClass(v, DeclarationLeft)
			)
		)
	}

	def static IScope getIScopeForAllContentsOfClass(EObject ctx, Class<? extends EObject> clazz){
		var root = EcoreUtil2.getRootContainer(ctx);						// get the root
		var candidates = EcoreUtil2.getAllContentsOfType(root, clazz);		// get all contents of type clazz
		return Scopes.scopeFor(candidates);									// return the scope
	}
	
	//utils: recursively get all free-names declarations until Script definition
	def static dispatch IScope getScopeForParameters(EObject cont, IScope outer) {
//		println("skipping: "+cont)
		return getScopeForParameters(cont.eContainer, outer);
	}
	
	def static dispatch IScope getScopeForParameters(Script obj, IScope outer) {
//		println('''adding params: [«obj.params.map[p|p.name+":"+p.type].join(",")»] from script «obj»''')
		return Scopes.scopeFor(
			obj.params,
			getScopeForParameters(obj.eContainer, outer)
		);
	}
	
	def static dispatch IScope getScopeForParameters(Receive obj, IScope outer) {
		return Scopes.scopeFor(
			newArrayList(obj.^var),
			getScopeForParameters(obj.eContainer, outer)
		);
	}

	def static dispatch IScope getScopeForParameters(Declaration obj, IScope outer) {
//		println('''adding params: [«obj.params.map[p|p.name+":"+p.type].join(",")»] from script «obj»''')
		return Scopes.scopeFor(obj.left.params, outer);
		// stop recursion
	}

	/**
	 * Key declarations are resolved within the same resource (file).
	 * <p>Keys are declared within a participant. If two participants
	 * use the same name for a key, the qualified name should be used
	 * (e.g. <code>Alice.k</code>)</p>
	 */
	def static IScope getScopeForParticipantDeclarations(EObject ctx, IScope outerScope) {
		var root = EcoreUtil2.getRootContainer(ctx);						// get the root
		var participants = EcoreUtil2.getAllContentsOfType(root, Participant);
		
//		val varsOccurrences = 	// a map for storing the number of occurrences of a key name 
//								// (if > 1, more than one participant is using that name)
//			EcoreUtil2.getAllContentsOfType(root, VariableDeclaration)	// all the keys declarations
//			.groupBy[k|k.name]											// group by name within a map String -> List<Key>
//			.entrySet													// to set
//			.map[e|e.key->e.value.size]									// convert to String -> N
//			.toMap([e|e.key],[e|e.value]);								// convert to a Map 
		
		val List<DeclarationLeft> candidates = newArrayList 
		for (p : participants) {
			candidates.addAll(p.variables.map[a|a.left])
		}

		Scopes.scopeFor(
			candidates, 
			[DeclarationLeft k|
				val participantName = EcoreUtil2.getContainerOfType(k, Participant).name
//				println('''adding variable: «k.name» from participant «participantName» ''')
				QualifiedName.create(participantName, k.name)				
			], 
			outerScope)
	}
}
