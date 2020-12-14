/*
 * FileDriver.swift
 * Created by Joseph Swistock on 11/11/20
 *
 * File contains the FileDriver class, which contains all code pertaining to Swift file I/O
 */

import Foundation

/*
 * This class is in charge of all Swift run file I/O in this program
 */
public class FileDriver{
    
    /*
     * Checks if a directory is in existance. If it is not, it creates it.
     *
     * Returns true if directory exists, false if not
     */
    static func prepareDirectory(path: String) -> Bool{
        
        /* Prepare URL */
        let url = URL(fileURLWithPath: path)
        
        /* Try to prepare the path */
        do{
            /* Check if the directory is reachable */
            if !(try url.checkResourceIsReachable()){
                
                /* Create file manager to create directory */
                let fm = FileManager.init()
                
                /* Create directory */
                try fm.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            }
            
            return true
        }
        
        /* Error in checking if file is reachable */
        catch{
            
            /* Program gets here if there was an error if directory is not reachable */
            do{
                /* Create file manager to create directory */
                let fm = FileManager.init()
                
                /* Create directory */
                try fm.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                
                return true
            }
            
            /* Error in creating directory */
            catch{
                return false
            }
        }
    }
    
    /*
     * Checks if a file exists, creates it if not
     *
     * Returns true if file now exists, false if error
     */
    static func prepareFile(path: String, initContents: String?) -> Bool{
        
        /* Create file manager to check existance of file */
        let fm = FileManager.init()
        
        /* If file exists at path */
        if !(fm.fileExists(atPath: path)){
            
            /* If initial contents of file is nil */
            if (initContents == nil){
                
                /* Write it with no contents */
                if !(FileDriver.writeASCII(path: path, contents: "")){
                    
                    /* If writing fails */
                    return false
                }
            }
            else{
                /* Write it with the given initial contents */
                if !(FileDriver.writeASCII(path: path, contents: initContents!)){
                    
                    /* If writing fails */
                    return false
                }
            }
            
        }
        return true
    }
    
    /*
     * Reads an ASCII file and returns a string containing it
     *
     * Returns a string containing the ASCII data, nil if error
     */
    static func readASCIIFile(path: String) -> String?{
        
        /* Try to read from file */
        do {
            /* Prepare file URL */
            let url = URL(fileURLWithPath: path)
            
            /* Read data from file */
            let data = try NSString(contentsOf: url, encoding: String.Encoding.utf8.rawValue)
            
            /* Return the result */
            return String(data)
        }
        
        /* If it's not on file */
        catch {
            return nil
        }
    }
    
    /*
     * Reads bytes from a file and returns the data
     *
     * Returns the data, nil if error
     */
    static func readByteFile(path: String) -> Data?{
        
        /* Try to read from file */
        do {
            /* Prepare file URL */
            let url = URL(fileURLWithPath: path)
            
            /* Read data from file */
            let data = try Data(contentsOf: url)
            
            /* Return the result */
            return data
        }
        
        /* If it's not on file */
        catch {
            return nil
        }
    }
    
    /*
     * Writes a string to the file given with path
     *
     * Returns true if it was successful, false if not
     */
    static func writeASCII(path: String, contents: String) -> Bool{
        
        /* Try to write to file */
        do{
            /* Prepare file URL */
            let url = URL(fileURLWithPath: path)
            
            /* Write contents to file */
            try contents.write(to: url, atomically: true, encoding: .utf8)
            
            return true
        }
        
        /* If there's an error */
        catch{
            return false
        }
    }
    
    /*
     * Writes data to a file with the given path and contents
     *
     * Returns true if it was successful, false if not
     */
    static func writeBytes(path: String, contents: Data) -> Bool{
        
        /* Try to write to file */
        do{
            /* Prepare file URL */
            let url = URL(fileURLWithPath: path)
            
            /* Write contents to file */
            try contents.write(to: url)
            
            return true
        }
        
        /* If there's an error */
        catch{
            return false
        }
    }
}
