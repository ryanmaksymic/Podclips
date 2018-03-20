//
//  AtomFeedContributor.swift
//
//  Copyright (c) 2017 Nuno Manuel Dias
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// The "atom:contributor" element is a Person construct that indicates a
/// person or other entity who contributed to the entry or feed.
public class AtomFeedContributor {
    
    /// The "atom:name" element's content conveys a human-readable name for
    /// the person.  The content of atom:name is Language-Sensitive.  Person
    /// constructs MUST contain exactly one "atom:name" element.
    public var name: String?
    
    /// The "atom:email" element's content conveys an e-mail address
    /// associated with the person.  Person constructs MAY contain an
    /// atom:email element, but MUST NOT contain more than one.  Its content
    /// MUST conform to the "addr-spec" production in [RFC2822].
    public var email: String?
    
    /// The "atom:uri" element's content conveys an IRI associated with the
    /// person.  Person constructs MAY contain an atom:uri element, but MUST
    /// NOT contain more than one.  The content of atom:uri in a Person
    /// construct MUST be an IRI reference [RFC3987].
    public var uri: String?
    
}

// MARK: - Equatable

extension AtomFeedContributor: Equatable {
    
    public static func ==(lhs: AtomFeedContributor, rhs: AtomFeedContributor) -> Bool {
        return
            lhs.name == rhs.name &&
            lhs.email == rhs.email &&
            lhs.uri == rhs.uri
    }
    
}
