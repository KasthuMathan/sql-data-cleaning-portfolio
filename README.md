# Nashville Housing Data Cleaning Project

## Project Overview
This data cleaning project is inspired by Alex Freberg's YouTube tutorial, adapted from SQL Server Management Studio to MySQL. The project demonstrates comprehensive data transformation and cleansing techniques on a Nashville housing dataset.

## Credit and Inspiration
- **Original Tutorial**: Alex Freberg's Data Cleaning Tutorial
- **Original Platform**: SQL Server Management Studio (SSMS)
- **Adaptation**: Translated and implemented using MySQL

## Technologies Used
- MySQL
- SQL Data Cleaning Techniques
- Adapted from SQL Server Management Studio (SSMS) workflow

## Key Differences in MySQL Adaptation
While following Alex Freberg's tutorial originally designed for SQL Server, several syntax and function adaptations were necessary:
- Replaced T-SQL specific functions with MySQL equivalents
- Adjusted string manipulation techniques
- Modified window function implementations
- Translated date conversion methods

### Specific Adaptation Challenges
- Converted SSMS-specific `CONVERT()` function to MySQL `STR_TO_DATE()`
- Replaced `SUBSTRING()` with `SUBSTRING_INDEX()`
- Adapted window function syntax for MySQL compatibility

## Data Cleaning Techniques Applied

### 1. Data Preparation
- Created a staging table to preserve original data
- Worked on a copy of the original dataset to maintain data integrity

### 2. Date Standardization
- Converted date strings to standard DATE format
- Used `REGEXP_REPLACE()` to remove ordinal suffixes (st, nd, rd, th)
- Transformed date format from text to proper MySQL DATE type

### 3. Handling Missing Values
- Converted blank rows to NULL values
- Used `NULLIF()` to replace empty strings with NULL
- Systematically checked and counted NULL values

### 4. Address Cleaning
#### Property Address
- Identified and filled missing property addresses
- Used self-join to match records with same ParcelID
- Implemented `IFNULL()` to populate missing addresses

#### Address Splitting
- Created separate columns for:
  - Property Split Address
  - Property Split City
- Used `SUBSTRING_INDEX()` to parse address components
- Repeated process for Owner's Address, creating:
  - Owner Split Address
  - Owner Split City
  - Owner Split State

### 5. Value Standardization
- Converted Y/N values to 'Yes'/'No' for clarity
- Used CASE statement to transform boolean-like columns

### 6. Duplicate Removal
- Utilized window function `ROW_NUMBER()` to identify duplicates
- Removed duplicate entries based on multiple criteria:
  - ParcelID
  - PropertyAddress
  - SalePrice
  - SaleDate
  - LegalReference

### 7. Column Management
- Removed unused columns to streamline the dataset
- Dropped redundant columns like PropertyAddress, OwnerAddress, TaxDistrict

## Key Cleaning Techniques Demonstrated
- Regular Expression Manipulation
- String Parsing
- Self-Joins for Data Enrichment
- Window Functions
- Conditional Updates
- NULL Handling

## SQL Skills Showcased
- Advanced `SELECT` statements
- `JOIN` operations
- Window functions
- `CASE` statements
- Data type conversions
- Table alterations

## Challenges Overcome
- Handling inconsistent date formats
- Filling missing address information
- Identifying and removing duplicate entries
- Transforming categorical data
- Adapting SQL Server techniques to MySQL

## Learning Outcomes
- Advanced SQL cross-platform translation skills
- Deep understanding of data cleaning techniques
- Ability to adapt tutorial-based learning to different SQL environments

## Acknowledgments
Special thanks to Alex Freberg for the original tutorial that inspired this project.
