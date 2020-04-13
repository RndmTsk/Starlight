//
//  ResourceManager.swift
//  Starlight
//
//  Created by Terry Latanville on 2019-05-16.
//  Copyright © 2019 Rndm Studio. All rights reserved.
//

import SpriteKit

public final class ResourceManager {
    // MARK: - Constants
    private struct Constants {
        static let densitySuffix = "@%.0fx%@"
    }

    // MARK: - Properties
    public static let shared = ResourceManager()
    private var loadedAtlases: [String: SKTextureAtlas] = [:]

    // MARK: - Functions
    public func atlas(named name: String) -> SKTextureAtlas {
        if let atlas = loadedAtlases[name] {
            return atlas
        }

        let atlas = SKTextureAtlas(named: name)
        loadedAtlases[name] = atlas

        return atlas
    }

    public func textures(from atlas: SKTextureAtlas, named textureName: String) -> [SKTexture] {
        let resolutionSuffix: String = suffix(forScale: UIScreen.main.scale, withExtension: ".png")
        return atlas.textureNames
            .sorted { $0 < $1 }
            .filter { $0.hasSuffix(resolutionSuffix) }
            .filter { $0.hasPrefix(textureName) }
            .map { atlas.textureNamed($0) }
    }

    public func texture(named name: String) -> String {
        return name.appendingFormat(suffix(forScale: UIScreen.main.scale))
    }

    private func suffix(forScale densityScale: CGFloat, withExtension fileExtension: String = "") -> String {
        if densityScale > 1 {
            return String(format: Constants.densitySuffix, arguments: [densityScale, fileExtension])
        } else {
            return fileExtension // TODO: (TL) This is likely a bug waiting to happen
        }
    }
}
