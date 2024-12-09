page 50233 "Contrato Archive Card"
{
    Caption = 'Project Archive Card';
    PageType = Document;
    DeleteAllowed = false;
    Editable = false;
    SourceTable = "Contrato Archive";
    AdditionalSearchTerms = 'Project, Archive';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Visible = NoFieldVisible;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies a short description of the project.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Customer No.';
                    Importance = Additional;
                    NotBlank = true;
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Customer Name';
                    Importance = Promoted;
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';
                }
                group("Sell-to")
                {
                    Caption = 'Sell-to';

                    field("Sell-to Address"; Rec."Sell-to Address")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Address';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address where the customer is located.';
                    }
                    field("Sell-to Address 2"; Rec."Sell-to Address 2")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Address 2';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Sell-to City"; Rec."Sell-to City")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'City';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the customer on the sales document.';
                    }
                    group(Control60)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                        field("Sell-to County"; Rec."Sell-to County")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'County';
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Sell-to Post Code"; Rec."Sell-to Post Code")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Post Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country or region of the address.';
                    }
                    field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Contact No.';
                        Importance = Additional;
                        ToolTip = 'Specifies the number of the contact person that the sales document will be sent to.';
                    }
                    field(SellToPhoneNo; SellToContact."Phone No.")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the telephone number of the contact person that the sales document will be sent to.';
                    }
                    field(SellToMobilePhoneNo; SellToContact."Mobile Phone No.")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Mobile Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the mobile telephone number of the contact person that the sales document will be sent to.';
                    }
                    field(SellToEmail; SellToContact."E-Mail")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Email';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = EMail;
                        ToolTip = 'Specifies the email address of the contact person that the sales document will be sent to.';
                    }
                    field("Sell-to Contact"; Rec."Sell-to Contact")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Contact';
                        Importance = Additional;
                        Editable = Rec."Sell-to Customer No." <> '';
                        ToolTip = 'Specifies the name of the person to contact at the customer.';
                    }
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = Contratos;
                    Importance = Additional;
                    ToolTip = 'Specifies an additional description of the project for searching purposes.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Contratos;
                    Importance = Promoted;
                    Tooltip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = Contratos;
                    Importance = Additional;
                    Tooltip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                }
                field("Person Responsible"; Rec."Person Responsible")
                {
                    ApplicationArea = Contratos;
                    Importance = Promoted;
                    ToolTip = 'Specifies the person at your company who is responsible for the project.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies when the project card was last modified.';
                }
                field("Project Manager"; Rec."Project Manager")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the person who is assigned to manage the project.';
                }
            }
            part(ContratoTaskLines; ContrTaskArchiveLinesSubform)
            {
                ApplicationArea = Contratos;
                Caption = 'Tasks';
                SubPageLink = "Contrato No." = field("No."),
                            "Version No." = field("Version No.");
                SubPageView = sorting("Contrato Task No.")
                              order(ascending);
            }
            group(Posting)
            {
                Caption = 'Posting';
                field(Status; Rec.Status)
                {
                    ApplicationArea = Contratos;
                    Importance = Promoted;
                    ToolTip = 'Specifies a current status of the project. You can change the status for the project as it progresses. Final calculations can be made on completed projects.';
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the posting group that links transactions made for the project with the appropriate general ledger accounts according to the general posting setup.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Contratos;
                    Importance = Promoted;
                    ToolTip = 'Specifies the location code of the project.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Contratos;
                    Importance = Promoted;
                    ToolTip = 'Specifies a bin code for specific location of the project.';
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = Contratos;
                    Importance = Additional;
                    ToolTip = 'Specifies the method that is used to calculate the value of work in process for the project.';
                }
                field("WIP Posting Method"; Rec."WIP Posting Method")
                {
                    ApplicationArea = Contratos;
                    Importance = Additional;
                    ToolTip = 'Specifies how WIP posting is performed. Per Project: The total WIP costs and the sales value is used to calculate WIP. Per Project Ledger Entry: The accumulated values of WIP costs and sales are used to calculate WIP.';
                }
                field("Allow Schedule/Contract Lines"; Rec."Allow Schedule/Contract Lines")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Allow Budget/Billable Lines';
                    Importance = Additional;
                    ToolTip = 'Specifies if you can add planning lines of both type Budget and type Billable to the project.';
                }
                field("Apply Usage Link"; Rec."Apply Usage Link")
                {
                    ApplicationArea = Contratos;
                    Importance = Additional;
                    ToolTip = 'Specifies whether usage entries, from the project journal or purchase line, for example, are linked to project planning lines. Select this check box if you want to be able to track the quantities and amounts of the remaining work needed to complete a project and to create a relationship between demand planning, usage, and sales. On a project card, you can select this check box if there are no existing project planning lines that include type Budget that have been posted. The usage link only applies to project planning lines that include type Budget.';
                }
            }
            group("Invoice and Shipping")
            {
                Caption = 'Invoice and Shipping';

                group("Bill-to")
                {
                    Caption = 'Bill-to';
                    field(BillToOptions; BillToOptions)
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Bill-to';
                        ToolTip = 'Specifies the customer that the sales invoice will be sent to. Default (Customer): The same as the customer on the sales invoice. Another Customer: Any customer that you specify in the fields below.';
                    }
                    group(Control205)
                    {
                        ShowCaption = false;
                        Visible = not (BillToOptions = BillToOptions::"Default (Customer)");

                        field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                        {
                            ApplicationArea = Contratos;
                            Importance = Promoted;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the number of the customer who pays for the project.';
                            Visible = false;
                        }
                        field("Bill-to Name"; Rec."Bill-to Name")
                        {
                            Caption = 'Name';
                            ApplicationArea = Contratos;
                            Importance = Promoted;
                            ToolTip = 'Specifies the name of the customer who pays for the project.';
                            Editable = ((BillToOptions = BillToOptions::"Another Customer") or ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName));
                            Enabled = ((BillToOptions = BillToOptions::"Another Customer") or ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName));
                            NotBlank = true;
                        }
                        field("Bill-to Address"; Rec."Bill-to Address")
                        {
                            Caption = 'Address';
                            ApplicationArea = Contratos;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the address of the customer to whom you will send the invoice.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to Address 2"; Rec."Bill-to Address 2")
                        {
                            Caption = 'Address 2';
                            ApplicationArea = Contratos;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies an additional line of the address.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to City"; Rec."Bill-to City")
                        {
                            Caption = 'City';
                            ApplicationArea = Contratos;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the city of the address.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        group(Control56)
                        {
                            ShowCaption = false;
                            Visible = IsBillToCountyVisible;
                            field("Bill-to County"; Rec."Bill-to County")
                            {
                                ApplicationArea = Contratos;
                                QuickEntry = false;
                                Importance = Additional;
                                ToolTip = 'Specifies the county code of the customer''s billing address.';
                                Caption = 'County';
                                Editable = BillToInformationEditable;
                                Enabled = BillToInformationEditable;
                            }
                        }
                        field("Bill-to Post Code"; Rec."Bill-to Post Code")
                        {
                            Caption = 'Post Code';
                            ApplicationArea = Contratos;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the postal code of the customer who pays for the project.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                        {
                            Caption = 'Country/Region';
                            ApplicationArea = Contratos;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the country/region code of the customer''s billing address.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;

                            trigger OnValidate()
                            begin
                                IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
                            end;
                        }
                        field("Bill-to Contact No."; Rec."Bill-to Contact No.")
                        {
                            Caption = 'Contact No.';
                            ApplicationArea = Contratos;
                            ToolTip = 'Specifies the number of the contact person at the customer''s billing address.';
                            Importance = Additional;
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field(ContactPhoneNo; BillToContact."Phone No.")
                        {
                            Caption = 'Phone No.';
                            ApplicationArea = Contratos;
                            Editable = false;
                            Importance = Additional;
                            ExtendedDatatype = PhoneNo;
                            ToolTip = 'Specifies the telephone number of the customer contact person for the project.';
                        }
                        field(ContactMobilePhoneNo; BillToContact."Mobile Phone No.")
                        {
                            Caption = 'Mobile Phone No.';
                            ApplicationArea = Contratos;
                            Editable = false;
                            Importance = Additional;
                            ExtendedDatatype = PhoneNo;
                            ToolTip = 'Specifies the mobile telephone number of the customer contact person for the project.';
                        }
                        field(ContactEmail; BillToContact."E-Mail")
                        {
                            Caption = 'Email';
                            ApplicationArea = Contratos;
                            ExtendedDatatype = EMail;
                            Editable = false;
                            Importance = Additional;
                            ToolTip = 'Specifies the email address of the customer contact person for the project.';
                        }
                        field("Bill-to Contact"; Rec."Bill-to Contact")
                        {
                            Caption = 'Contact';
                            ApplicationArea = Contratos;
                            Importance = Additional;
                            ToolTip = 'Specifies the name of the contact person at the customer who pays for the project.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                    }
                }
                group("Payment Terms")
                {
                    caption = 'Payment Terms';

                    field("Payment Terms Code"; Rec."Payment Terms Code")
                    {
                        ApplicationArea = Contratos;
                        Tooltip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    }
                    field("Payment Method Code"; Rec."Payment Method Code")
                    {
                        ApplicationArea = Contratos;
                        Tooltip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                        Importance = Additional;
                    }
                }
                group("Ship-to")
                {
                    Caption = 'Ship-to';

                    field(ShippingOptions; ShipToOptions)
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Ship-to';
                        ToolTip = 'Specifies the address that the products on the sales document are shipped to. Default (Sell-to Address): The same as the customer''s sell-to address. Alternate Ship-to Address: One of the customer''s alternate ship-to addresses. Custom Address: Any ship-to address that you specify in the fields below.';
                    }
                    group(Control202)
                    {
                        ShowCaption = false;
                        Visible = not (ShipToOptions = ShipToOptions::"Default (Sell-to Address)");
                        field("Ship-to Code"; Rec."Ship-to Code")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Code';
                            Editable = ShipToOptions = ShipToOptions::"Alternate Shipping Address";
                            Importance = Promoted;
                            ToolTip = 'Specifies the code for another shipment address than the customer''s own address, which is entered by default.';
                        }
                        field("Ship-to Name"; Rec."Ship-to Name")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Name';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            ToolTip = 'Specifies the name that products on the sales document will be shipped to.';
                        }
                        field("Ship-to Address"; Rec."Ship-to Address")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Address';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the address that products on the sales document will be shipped to.';
                        }
                        field("Ship-to Address 2"; Rec."Ship-to Address 2")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Address 2';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies additional address information.';
                        }
                        field("Ship-to City"; Rec."Ship-to City")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'City';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the city of the customer on the sales document.';
                        }
                        group(Control82)
                        {
                            ShowCaption = false;
                            Visible = IsShipToCountyVisible;
                            field("Ship-to County"; Rec."Ship-to County")
                            {
                                ApplicationArea = Contratos;
                                Caption = 'County';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                QuickEntry = false;
                                ToolTip = 'Specifies the state, province or county of the address.';
                            }
                        }
                        field("Ship-to Post Code"; Rec."Ship-to Post Code")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Post Code';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the postal code.';
                        }
                        field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Country/Region';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the customer''s country/region.';

                            trigger OnValidate()
                            begin
                                IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
                            end;
                        }
                    }
                    field("Ship-to Contact"; Rec."Ship-to Contact")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Contact';
                        ToolTip = 'Specifies the name of the contact person at the address that products on the sales document will be shipped to.';
                    }
                }
            }
            group(Duration)
            {
                Caption = 'Duration';
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Contratos;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date on which the project actually starts.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Contratos;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date on which the project is expected to be completed.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the date on which you set up the project.';
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency code for the project. By default, the currency code is empty. If you enter a foreign currency code, it results in the project being planned and invoiced in that currency.';
                }
                field("Invoice Currency Code"; Rec."Invoice Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code you want to apply when creating invoices for a project. By default, the invoice currency code for a project is based on what currency code is defined on the customer card.';
                }
                field("Price Calculation Method"; Rec."Price Calculation Method")
                {
                    Visible = ExtendedPriceEnabled;
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the default method of the unit price calculation.';
                }
                field("Cost Calculation Method"; Rec."Cost Calculation Method")
                {
                    Visible = ExtendedPriceEnabled;
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the default method of the unit cost calculation.';
                }
                field("Exch. Calculation (Cost)"; Rec."Exch. Calculation (Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how project costs are calculated if you change the Currency Date or the Currency Code fields on a project planning Line or run the Change Project Planning Line Dates batch project. Fixed LCY option: The project costs in the local currency are fixed. Any change in the currency exchange rate will change the value of project costs in a foreign currency. Fixed FCY option: The project costs in a foreign currency are fixed. Any change in the currency exchange rate will change the value of project costs in the local currency.';
                }
                field("Exch. Calculation (Price)"; Rec."Exch. Calculation (Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how project sales prices are calculated if you change the Currency Date or the Currency Code fields on a project planning Line or run the Change Project Planning Line Dates batch project. Fixed LCY option: The project prices in the local currency are fixed. Any change in the currency exchange rate will change the value of project prices in a foreign currency. Fixed FCY option: The project prices in a foreign currency are fixed. Any change in the currency exchange rate will change the value of project prices in the local currency.';
                }
            }
            group(Version)
            {
                Caption = 'Version';
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the version number of the archived document.';
                }
                field("Archived By"; Rec."Archived By")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the user ID of the person who archived this document.';

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."Archived By");
                    end;
                }
                field("Date Archived"; Rec."Date Archived")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the date when the document was archived.';
                }
                field("Time Archived"; Rec."Time Archived")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies what time the document was archived.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = true;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Contrato")
            {
                Caption = '&Project';
                Image = Job;
                action(ContratoPlanningLines)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Project &Planning Lines';
                    Image = JobLines;
                    ToolTip = 'View all planning lines for the project. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a project (Budget) or you can specify what you actually agreed with your customer that he should pay for the project (Billable).';

                    trigger OnAction()
                    var
                        ContratoPlanningLineArchive: Record "Contrato Planning Line Archive";
                        ContratoPlanningArchiveLines: Page "ContratoPlanningArchiveLines";
                    begin
                        Rec.TestField("No.");
                        ContratoPlanningLineArchive.FilterGroup(2);
                        ContratoPlanningLineArchive.SetRange("Contrato No.", Rec."No.");
                        ContratoPlanningLineArchive.SetRange("Version No.", Rec."Version No.");
                        ContratoPlanningLineArchive.FilterGroup(0);
                        ContratoPlanningArchiveLines.SetTableView(ContratoPlanningLineArchive);
                        ContratoPlanningArchiveLines.Run();
                    end;
                }
                separator(Action64)
                {
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet Archive";
                    RunPageLink = "Table Name" = const(Contrato),
                                  "No." = field("No."),
                                  "Version No." = field("Version No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action("&Online Map")
                {
                    ApplicationArea = Contratos;
                    Caption = '&Online Map';
                    Image = Map;
                    ToolTip = 'View online map for addresses assigned to this project.';

                    trigger OnAction()
                    begin
                        Rec.DisplayMap();
                    end;
                }
            }
        }
        area(processing)
        {
            action(Restore)
            {
                ApplicationArea = Suite;
                Caption = '&Restore';
                Ellipsis = true;
                Image = Restore;
                ToolTip = 'Transfer the contents of this archived version to the original project.';

                trigger OnAction()
                var
                    ContratoArchiveManagement: Codeunit "Contrato Archive Management";
                begin
                    ContratoArchiveManagement.RestoreContrato(Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Restore_Promoted; Restore)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Project', Comment = 'Generated from the PromotedActionCategories property index 6.';

                actionref("Co&mments_Promoted"; "Co&mments")
                {
                }
                separator(Navigate_Separator)
                {
                }
                actionref(ContratoPlanningLines_Promoted; ContratoPlanningLines)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Navigate', Comment = 'Generated from the PromotedActionCategories property index 5.';
            }
        }
    }

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        SetNoFieldVisible();
        ActivateFields();
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if GuiAllowed() then
            SetControlVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        if GuiAllowed() then
            SetControlVisibility();
        UpdateShipToBillToGroupVisibility();
        SellToContact.GetOrClear(Rec."Sell-to Contact No.");
        BillToContact.GetOrClear(Rec."Bill-to Contact No.");
        UpdateBillToInformationEditable();
    end;

    var
        FormatAddress: Codeunit "Format Address";
        NoFieldVisible: Boolean;
        ExtendedPriceEnabled: Boolean;
        IsBillToCountyVisible: Boolean;
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;
        BillToInformationEditable: Boolean;
        ShouldSearchForCustByName: Boolean;

    protected var
        SellToContact: Record Contact;
        BillToContact: Record Contact;
        ShipToOptions: Enum "Sales Ship-to Options";
        BillToOptions: Enum "Sales Bill-to Options";

    local procedure SetNoFieldVisible()
    var
        DocumentNoVisibility: Codeunit DocumentNoVisibility;
    begin
        NoFieldVisible := DocumentNoVisibility.JobNoIsVisible();
    end;

    local procedure ActivateFields()
    begin
        IsBillToCountyVisible := FormatAddress.UseCounty(Rec."Bill-to Country/Region Code");
        IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Sell-to Country/Region Code");
        IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
    end;

    local procedure UpdateShipToBillToGroupVisibility()
    begin
        case true of
            (Rec."Ship-to Code" = '') and Rec.ShipToNameEqualsSellToName() and Rec.ShipToAddressEqualsSellToAddress():
                ShipToOptions := ShipToOptions::"Default (Sell-to Address)";

            (Rec."Ship-to Code" = '') and (not Rec.ShipToNameEqualsSellToName() or not Rec.ShipToAddressEqualsSellToAddress()):
                ShipToOptions := ShipToOptions::"Custom Address";

            Rec."Ship-to Code" <> '':
                ShipToOptions := ShipToOptions::"Alternate Shipping Address";
        end;

        case true of
            (Rec."Bill-to Customer No." = Rec."Sell-to Customer No.") and Rec.BillToAddressEqualsSellToAddress():
                BillToOptions := BillToOptions::"Default (Customer)";

            (Rec."Bill-to Customer No." = Rec."Sell-to Customer No.") and (not Rec.BillToAddressEqualsSellToAddress()):
                BillToOptions := BillToOptions::"Custom Address";

            Rec."Bill-to Customer No." <> Rec."Sell-to Customer No.":
                BillToOptions := BillToOptions::"Another Customer";
        end;
    end;

    local procedure UpdateBillToInformationEditable()
    begin
        BillToInformationEditable :=
            (BillToOptions = BillToOptions::"Custom Address") or
            (Rec."Bill-to Customer No." <> Rec."Sell-to Customer No.");
    end;

    local procedure SetControlVisibility()
    begin
        ShouldSearchForCustByName := Rec.ShouldSearchForCustomerByName(Rec."Sell-to Customer No.");
    end;
}