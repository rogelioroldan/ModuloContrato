
page 50201 "Contrato Card"
{
    Caption = 'Contrato Card';
    PageType = Document;
    RefreshOnActivate = true;
    SourceTable = Contrato;
    AdditionalSearchTerms = 'Contrato Card';

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

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies a short description of the Contrato.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer No.';
                    Importance = Additional;
                    NotBlank = true;
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Name';
                    Importance = Promoted;
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';

                    trigger OnValidate()
                    begin
                        Rec.SelltoCustomerNoOnAfterValidate(Rec, xRec);
                        CurrPage.Update();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LookupSellToCustomerName(Text));
                    end;
                }
                group("Sell-to")
                {
                    Caption = 'Sell-to';

                    field("Sell-to Address"; Rec."Sell-to Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address where the customer is located.';
                    }
                    field("Sell-to Address 2"; Rec."Sell-to Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field("Sell-to City"; Rec."Sell-to City")
                    {
                        ApplicationArea = All;
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
                            ApplicationArea = All;
                            Caption = 'County';
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the state, province or county of the address.';
                        }
                    }
                    field("Sell-to Post Code"; Rec."Sell-to Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Post Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Sell-to Country/Region Code"; Rec."Sell-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country/Region Code';
                        Importance = Additional;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country or region of the address.';

                        trigger OnValidate()
                        begin
                            IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Sell-to Country/Region Code");
                        end;
                    }
                    field("Sell-to Contact No."; Rec."Sell-to Contact No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact No.';
                        Importance = Additional;
                        ToolTip = 'Specifies the number of the contact person that the sales document will be sent to.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if not Rec.SelltoContactLookup() then
                                exit(false);
                            Text := Rec."Sell-to Contact No.";
                            SellToContact.Get(Rec."Sell-to Contact No.");
                            Rec."Sell-to Contact" := SellToContact.Name;
                            CurrPage.Update();
                            exit(true);
                        end;

                        trigger OnValidate()
                        begin
                            SellToContact.Get(Rec."Sell-to Contact No.");
                            Rec."Sell-to Contact" := SellToContact.Name;
                            CurrPage.Update();
                        end;
                    }
                    field(SellToPhoneNo; SellToContact."Phone No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the telephone number of the contact person that the sales document will be sent to.';
                    }
                    field(SellToMobilePhoneNo; SellToContact."Mobile Phone No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Mobile Phone No.';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = PhoneNo;
                        ToolTip = 'Specifies the mobile telephone number of the contact person that the sales document will be sent to.';
                    }
                    field(SellToEmail; SellToContact."E-Mail")
                    {
                        ApplicationArea = All;
                        Caption = 'Email';
                        Importance = Additional;
                        Editable = false;
                        ExtendedDatatype = EMail;
                        ToolTip = 'Specifies the email address of the contact person that the sales document will be sent to.';
                    }
                    field("Sell-to Contact"; Rec."Sell-to Contact")
                    {
                        ApplicationArea = All;
                        Caption = 'Contact';
                        Importance = Additional;
                        Editable = Rec."Sell-to Customer No." <> '';
                        ToolTip = 'Specifies the name of the person to contact at the customer.';
                    }
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies an additional description of the Contrato for searching purposes.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    Tooltip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Tooltip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                }
                field("Person Responsible"; Rec."Person Responsible")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the person at your company who is responsible for the Contrato.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the related record is blocked from being posted in transactions, for example a customer that is declared insolvent or an item that is placed in quarantine.';
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the Contrato card was last modified.';
                }
                field("Project Manager"; Rec."Project Manager")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the person who is assigned to manage the Contrato.';
                }
                field("No. of Archived Versions"; Rec."No. of Archived Versions")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of archived versions of this Contrato.';
                }
            }
            part(ContratoTaskLines; "Contrato Task Lines Subform")
            {
                ApplicationArea = All;
                Caption = 'Planeación';
                SubPageLink = "Contrato No." = field("No.");
                SubPageView = sorting("Contrato Task No.")
                              order(ascending);
                UpdatePropagation = Both;
                Editable = ContratoTaskLinesEditable;
                Enabled = ContratoTaskLinesEditable;
            }
            group(Posting)
            {
                Caption = 'Posting';
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies a current status of the Contrato. You can change the status for the Contrato as it progresses. Final calculations can be made on completed Contratos.';

                    trigger OnValidate()
                    begin
                        if (Rec.Status = Rec.Status::Completed) and Rec.Complete then begin
                            //Rec.RecalculateContratoWIP();
                            CurrPage.Update(false);
                        end;
                    end;
                }
                // field("Contrato Posting Group"; Rec."Contrato Posting Group")
                // {
                //     ApplicationArea = All;
                //     Importance = Promoted;
                //     ToolTip = 'Specifies the posting group that links transactions made for the Contrato with the appropriate general ledger accounts according to the general posting setup.';
                // }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the location code of the Contrato.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies a bin code for specific location of the Contrato.';
                }
                // field("WIP Method"; Rec."WIP Method")
                // {
                //     ApplicationArea = All;
                //     Importance = Additional;
                //     ToolTip = 'Specifies the method that is used to calculate the value of work in process for the Contrato.';
                // }
                field("WIP Posting Method"; Rec."WIP Posting Method")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies how WIP posting is performed. Per Contrato: The total WIP costs and the sales value is used to calculate WIP. Per Contrato Ledger Entry: The accumulated values of WIP costs and sales are used to calculate WIP.';
                }
                field("Allow Schedule/Contract Lines"; Rec."Allow Schedule/Contract Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Allow Budget/Billable Lines';
                    Importance = Additional;
                    ToolTip = 'Specifies if you can add planning lines of both type Budget and type Billable to the Contrato.';
                }
                field("Apply Usage Link"; Rec."Apply Usage Link")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies whether usage entries, from the Contrato journal or purchase line, for example, are linked to Contrato planning lines. Select this check box if you want to be able to track the quantities and amounts of the remaining work needed to complete a Contrato and to create a relationship between demand planning, usage, and sales. On a Contrato card, you can select this check box if there are no existing Contrato planning lines that include type Budget that have been posted. The usage link only applies to Contrato planning lines that include type Budget.';
                }
                field("% Completed"; Rec.PercentCompleted())
                {
                    ApplicationArea = All;
                    Caption = '% Completed';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the percentage of the Contrato''s estimated resource usage that has been posted as used.';
                }
                field("% Invoiced"; Rec.PercentInvoiced())
                {
                    ApplicationArea = All;
                    Caption = '% Invoiced';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the percentage of the Contrato''s invoice value that has been posted as invoiced.';
                }
                field("% of Overdue Planning Lines"; Rec.PercentOverdue())
                {
                    ApplicationArea = All;
                    Caption = '% of Overdue Planning Lines';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the percentage of the Contrato''s planning lines where the planned delivery date has been exceeded.';
                }
            }
            group("Invoice and Shipping")
            {
                Caption = 'Invoice and Shipping';

                field("Task Billing Method"; Rec."Task Billing Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify whether to use the customer specified for the Contrato for all tasks or allow people to specify different customers. One customer lets you invoice only the customer specified for the Contrato. Multiple customers lets you invoice customers specified on each task, which can be different customers.';

                    trigger OnValidate()
                    begin
                        CurrPage.ContratoTaskLines.Page.SetPerTaskBillingFieldsVisible(Rec."Task Billing Method" = Rec."Task Billing Method"::"Multiple customers");
                        CurrPage.Update(false);
                    end;
                }
                group("Bill-to")
                {
                    Caption = 'Bill-to';
                    field(BillToOptions; BillToOptions)
                    {
                        ApplicationArea = All;
                        Caption = 'Bill-to';
                        ToolTip = 'Specifies the customer that the sales invoice will be sent to. Default (Customer): The same as the customer on the sales invoice. Another Customer: Any customer that you specify in the fields below.';

                        trigger OnValidate()
                        begin
                            if BillToOptions = BillToOptions::"Default (Customer)" then begin
                                Rec.Validate("Bill-to Customer No.", Rec."Sell-to Customer No.");
                                Rec.Validate("Bill-to Contact No.", Rec."Sell-to Contact No.");
                            end;

                            UpdateBillToInformationEditable();
                        end;
                    }
                    group(Control205)
                    {
                        ShowCaption = false;
                        Visible = not (BillToOptions = BillToOptions::"Default (Customer)");

                        field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                        {
                            ApplicationArea = All;
                            Importance = Promoted;
                            ShowMandatory = true;
                            ToolTip = 'Specifies the number of the customer who pays for the Contrato.';
                            Visible = false;

                            trigger OnValidate()
                            begin
                                CurrPage.Update();
                            end;
                        }
                        field("Bill-to Name"; Rec."Bill-to Name")
                        {
                            Caption = 'Name';
                            ApplicationArea = All;
                            Importance = Promoted;
                            ToolTip = 'Specifies the name of the customer who pays for the Contrato.';
                            Editable = ((BillToOptions = BillToOptions::"Another Customer") or ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName));
                            Enabled = ((BillToOptions = BillToOptions::"Another Customer") or ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName));
                            NotBlank = true;

                            trigger OnValidate()
                            begin
                                if not ((BillToOptions = BillToOptions::"Custom Address") and not ShouldSearchForCustByName) then begin
                                    if Rec.GetFilter("Bill-to Customer No.") = xRec."Bill-to Customer No." then
                                        if Rec."Bill-to Customer No." <> xRec."Bill-to Customer No." then
                                            Rec.SetRange("Bill-to Customer No.");

                                    CurrPage.Update();
                                end;
                            end;
                        }
                        field("Bill-to Address"; Rec."Bill-to Address")
                        {
                            Caption = 'Address';
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the address of the customer to whom you will send the invoice.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to Address 2"; Rec."Bill-to Address 2")
                        {
                            Caption = 'Address 2';
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies an additional line of the address.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to City"; Rec."Bill-to City")
                        {
                            Caption = 'City';
                            ApplicationArea = All;
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
                                ApplicationArea = All;
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
                            ApplicationArea = All;
                            Importance = Additional;
                            QuickEntry = false;
                            ToolTip = 'Specifies the postal code of the customer who pays for the Contrato.';
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;
                        }
                        field("Bill-to Country/Region Code"; Rec."Bill-to Country/Region Code")
                        {
                            Caption = 'Country/Region';
                            ApplicationArea = All;
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
                            ApplicationArea = All;
                            ToolTip = 'Specifies the number of the contact person at the customer''s billing address.';
                            Importance = Additional;
                            Editable = BillToInformationEditable;
                            Enabled = BillToInformationEditable;

                            trigger OnLookup(var Text: Text): Boolean
                            begin
                                if not Rec.BilltoContactLookup() then
                                    exit(false);
                                BillToContact.Get(Rec."Bill-to Contact No.");
                                Text := Rec."Bill-to Contact No.";
                                exit(true);
                            end;

                            trigger OnValidate()
                            begin
                                BillToContact.Get(Rec."Bill-to Contact No.");
                            end;
                        }
                        field(ContactPhoneNo; BillToContact."Phone No.")
                        {
                            Caption = 'Phone No.';
                            ApplicationArea = All;
                            Editable = false;
                            Importance = Additional;
                            ExtendedDatatype = PhoneNo;
                            ToolTip = 'Specifies the telephone number of the customer contact person for the Contrato.';
                        }
                        field(ContactMobilePhoneNo; BillToContact."Mobile Phone No.")
                        {
                            Caption = 'Mobile Phone No.';
                            ApplicationArea = All;
                            Editable = false;
                            Importance = Additional;
                            ExtendedDatatype = PhoneNo;
                            ToolTip = 'Specifies the mobile telephone number of the customer contact person for the Contrato.';
                        }
                        field(ContactEmail; BillToContact."E-Mail")
                        {
                            Caption = 'Email';
                            ApplicationArea = All;
                            ExtendedDatatype = EMail;
                            Editable = false;
                            Importance = Additional;
                            ToolTip = 'Specifies the email address of the customer contact person for the Contrato.';
                        }
                        field("Bill-to Contact"; Rec."Bill-to Contact")
                        {
                            Caption = 'Contact';
                            ApplicationArea = All;
                            Importance = Additional;
                            ToolTip = 'Specifies the name of the contact person at the customer who pays for the Contrato.';
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
                        ApplicationArea = All;
                        Tooltip = 'Specifies a formula that calculates the payment due date, payment discount date, and payment discount amount.';
                    }
                    field("Payment Method Code"; Rec."Payment Method Code")
                    {
                        ApplicationArea = All;
                        Tooltip = 'Specifies how to make payment, such as with bank transfer, cash, or check.';
                        Importance = Additional;
                    }
                }
                group("Ship-to")
                {
                    Caption = 'Ship-to';

                    field(ShippingOptions; ShipToOptions)
                    {
                        ApplicationArea = All;
                        Caption = 'Ship-to';
                        ToolTip = 'Specifies the address that the products on the sales document are shipped to. Default (Sell-to Address): The same as the customer''s sell-to address. Alternate Ship-to Address: One of the customer''s alternate ship-to addresses. Custom Address: Any ship-to address that you specify in the fields below.';

                        trigger OnValidate()
                        var
                            ShipToAddress: Record "Ship-to Address";
                            ShipToAddressList: Page "Ship-to Address List";
                        begin
                            case ShipToOptions of
                                ShipToOptions::"Default (Sell-to Address)":
                                    begin
                                        Rec.Validate("Ship-to Code", '');
                                        Rec.SyncShipToWithSellTo();
                                    end;
                                ShipToOptions::"Alternate Shipping Address":
                                    begin
                                        ShipToAddress.SetRange("Customer No.", Rec."Sell-to Customer No.");
                                        ShipToAddressList.LookupMode := true;
                                        ShipToAddressList.SetTableView(ShipToAddress);

                                        if ShipToAddressList.RunModal() = ACTION::LookupOK then begin
                                            ShipToAddressList.GetRecord(ShipToAddress);
                                            Rec.Validate("Ship-to Code", ShipToAddress.Code);
                                            IsShipToCountyVisible := FormatAddress.UseCounty(ShipToAddress."Country/Region Code");
                                        end else
                                            ShipToOptions := ShipToOptions::"Custom Address";
                                    end;
                                ShipToOptions::"Custom Address":
                                    begin
                                        Rec.Validate("Ship-to Code", '');
                                        IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
                                    end;
                            end;
                        end;
                    }
                    group(Control202)
                    {
                        ShowCaption = false;
                        Visible = not (ShipToOptions = ShipToOptions::"Default (Sell-to Address)");
                        field("Ship-to Code"; Rec."Ship-to Code")
                        {
                            ApplicationArea = All;
                            Caption = 'Code';
                            Editable = ShipToOptions = ShipToOptions::"Alternate Shipping Address";
                            Importance = Promoted;
                            ToolTip = 'Specifies the code for another shipment address than the customer''s own address, which is entered by default.';

                            trigger OnValidate()
                            var
                                ShipToAddress: Record "Ship-to Address";
                            begin
                                if (xRec."Ship-to Code" <> '') and (Rec."Ship-to Code" = '') then
                                    Error(EmptyShipToCodeErr);
                                if Rec."Ship-to Code" <> '' then begin
                                    ShipToAddress.Get(Rec."Sell-to Customer No.", Rec."Ship-to Code");
                                    IsShipToCountyVisible := FormatAddress.UseCounty(ShipToAddress."Country/Region Code");
                                end else
                                    IsShipToCountyVisible := false;
                            end;
                        }
                        field("Ship-to Name"; Rec."Ship-to Name")
                        {
                            ApplicationArea = All;
                            Caption = 'Name';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            ToolTip = 'Specifies the name that products on the sales document will be shipped to.';
                        }
                        field("Ship-to Address"; Rec."Ship-to Address")
                        {
                            ApplicationArea = All;
                            Caption = 'Address';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the address that products on the sales document will be shipped to.';
                        }
                        field("Ship-to Address 2"; Rec."Ship-to Address 2")
                        {
                            ApplicationArea = All;
                            Caption = 'Address 2';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies additional address information.';
                        }
                        field("Ship-to City"; Rec."Ship-to City")
                        {
                            ApplicationArea = All;
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
                                ApplicationArea = All;
                                Caption = 'County';
                                Editable = ShipToOptions = ShipToOptions::"Custom Address";
                                QuickEntry = false;
                                ToolTip = 'Specifies the state, province or county of the address.';
                            }
                        }
                        field("Ship-to Post Code"; Rec."Ship-to Post Code")
                        {
                            ApplicationArea = All;
                            Caption = 'Post Code';
                            Editable = ShipToOptions = ShipToOptions::"Custom Address";
                            QuickEntry = false;
                            ToolTip = 'Specifies the postal code.';
                        }
                        field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                        {
                            ApplicationArea = All;
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
                        ApplicationArea = All;
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
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date on which the Contrato actually starts.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the date on which the Contrato is expected to be completed.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date on which you set up the Contrato.';
                }
            }
            group("Foreign Trade")
            {
                Caption = 'Foreign Trade';
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the currency code for the Contrato. By default, the currency code is empty. If you enter a foreign currency code, it results in the Contrato being planned and invoiced in that currency.';
                }
                field("Invoice Currency Code"; Rec."Invoice Currency Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the currency code you want to apply when creating invoices for a Contrato. By default, the invoice currency code for a Contrato is based on what currency code is defined on the customer card.';
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
                    ToolTip = 'Specifies how Contrato costs are calculated if you change the Currency Date or the Currency Code fields on a Contrato planning Line or run the Change Contrato Planning Line Dates batch Contrato. Fixed LCY option: The Contrato costs in the local currency are fixed. Any change in the currency exchange rate will change the value of Contrato costs in a foreign currency. Fixed FCY option: The Contrato costs in a foreign currency are fixed. Any change in the currency exchange rate will change the value of Contrato costs in the local currency.';
                }
                field("Exch. Calculation (Price)"; Rec."Exch. Calculation (Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies how Contrato sales prices are calculated if you change the Currency Date or the Currency Code fields on a Contrato planning Line or run the Change Contrato Planning Line Dates batch Contrato. Fixed LCY option: The Contrato prices in the local currency are fixed. Any change in the currency exchange rate will change the value of Contrato prices in a foreign currency. Fixed FCY option: The Contrato prices in a foreign currency are fixed. Any change in the currency exchange rate will change the value of Contrato prices in the local currency.';
                }
                field("Language Code"; Rec."Language Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the language to be used on printouts for this Contrato.';
                    Visible = false;
                }
            }
            group("WIP and Recognition")
            {
                Caption = 'WIP and Recognition';
                group("To Post")
                {
                    Caption = 'To Post';
                    field("WIP Posting Date"; Rec."WIP Posting Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the posting date that was entered when the Contrato Calculate WIP batch Contrato was last run.';
                    }
                    field("Total WIP Sales Amount"; Rec."Total WIP Sales Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the total WIP sales amount that was last calculated for the Contrato. The WIP sales amount is the value in the WIP Sales Contrato WIP Entries window minus the value of the Recognized Sales Contrato WIP Entries window. For Contratos with the Cost Value or Cost of Sales WIP methods, the WIP sales amount is normally 0.';
                    }
                    field("Applied Sales G/L Amount"; Rec."Applied Sales G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sum of all applied sales in the general ledger that are related to the Contrato.';
                        Visible = false;
                    }
                    field("Total WIP Cost Amount"; Rec."Total WIP Cost Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the total WIP cost amount that was last calculated for the Contrato. The WIP cost amount is the value in the WIP Cost Contrato WIP Entries window minus the value of the Recognized Cost Contrato WIP Entries window. For Contratos with Sales Value or Percentage of Completion WIP methods, the WIP cost amount is normally 0.';
                    }
                    field("Applied Costs G/L Amount"; Rec."Applied Costs G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sum of all applied costs that is based on to the selected Contrato in the general ledger.';
                        Visible = false;
                    }
                    field("Recog. Sales Amount"; Rec."Recog. Sales Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the recognized sales amount that was last calculated for the Contrato, which is the sum of the Recognized Sales Contrato WIP Entries.';
                    }
                    field("Recog. Costs Amount"; Rec."Recog. Costs Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the recognized cost amount that was last calculated for the Contrato. The value is the sum of the entries in the Recognized Cost Contrato WIP Entries window.';
                    }
                    field("Recog. Profit Amount"; Rec.CalcRecognizedProfitAmount())
                    {
                        ApplicationArea = All;
                        Caption = 'Recog. Profit Amount';
                        ToolTip = 'Specifies the recognized profit amount for the Contrato.';
                    }
                    field("Recog. Profit %"; Rec.CalcRecognizedProfitPercentage())
                    {
                        ApplicationArea = All;
                        Caption = 'Recog. Profit %';
                        ToolTip = 'Specifies the recognized profit percentage for the Contrato.';
                    }
                    field("Acc. WIP Costs Amount"; Rec.CalcAccWIPCostsAmount())
                    {
                        ApplicationArea = All;
                        Caption = 'Acc. WIP Costs Amount';
                        ToolTip = 'Specifies the total WIP costs for the Contrato.';
                        Visible = false;
                    }
                    field("Acc. WIP Sales Amount"; Rec.CalcAccWIPSalesAmount())
                    {
                        ApplicationArea = All;
                        Caption = 'Acc. WIP Sales Amount';
                        ToolTip = 'Specifies the total WIP sales for the Contrato.';
                        Visible = false;
                    }
                    field("Calc. Recog. Sales Amount"; Rec."Calc. Recog. Sales Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sum of the recognized sales amount that is associated with Contrato tasks for the Contrato.';
                        Visible = false;
                    }
                    field("Calc. Recog. Costs Amount"; Rec."Calc. Recog. Costs Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sum of the recognized costs amount that is associated with Contrato tasks for the Contrato.';
                        Visible = false;
                    }
                }
                group(Posted)
                {
                    Caption = 'Posted';
                    field("WIP G/L Posting Date"; Rec."WIP G/L Posting Date")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the posting date that was entered when the Contrato Post WIP to General Ledger batch Contrato was last run.';
                    }
                    field("Total WIP Sales G/L Amount"; Rec."Total WIP Sales G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the total WIP sales amount that was last posted to the general ledger for the Contrato. The WIP sales amount is the value in the WIP Sales Contrato WIP G/L Entries window minus the value in the Recognized Sales Contrato WIP G/L Entries window. For Contratos with the Cost Value or Cost of Sales WIP methods, the WIP sales amount is normally 0.';
                    }
                    field("Total WIP Cost G/L Amount"; Rec."Total WIP Cost G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the total WIP Cost amount that was last posted to the G/L for the Contrato. The WIP Cost Amount for the Contrato is the value WIP Cost Contrato WIP G/L Entries less the value of the Recognized Cost Contrato WIP G/L Entries. For Contratos with WIP Methods of Sales Value or Percentage of Completion, the WIP Cost Amount is normally 0.';
                    }
                    field("Recog. Sales G/L Amount"; Rec."Recog. Sales G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the total recognized sales amount that was last posted to the general ledger for the Contrato. The recognized sales G/L amount for the Contrato is the sum of the entries in the Recognized Sales Contrato WIP G/L Entries window.';
                    }
                    field("Recog. Costs G/L Amount"; Rec."Recog. Costs G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the total Recognized Cost amount that was last posted to the general ledger for the Contrato. The Recognized Cost G/L amount for the Contrato is the sum of the Recognized Cost Contrato WIP G/L Entries.';
                    }
                    field("Recog. Profit G/L Amount"; Rec.CalcRecognizedProfitGLAmount())
                    {
                        ApplicationArea = All;
                        Caption = 'Recog. Profit G/L Amount';
                        ToolTip = 'Specifies the profit amount that is recognized with the general ledger for the Contrato.';
                    }
                    field("Recog. Profit G/L %"; Rec.CalcRecognProfitGLPercentage())
                    {
                        ApplicationArea = All;
                        Caption = 'Recog. Profit G/L %';
                        ToolTip = 'Specifies the profit percentage that is recognized with the general ledger for the Contrato.';
                    }
                    field("Calc. Recog. Sales G/L Amount"; Rec."Calc. Recog. Sales G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sum of the recognized sales general ledger amount that is associated with Contrato tasks for the Contrato.';
                        Visible = false;
                    }
                    field("Calc. Recog. Costs G/L Amount"; Rec."Calc. Recog. Costs G/L Amount")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sum of the recognized costs general ledger amount that is associated with Contrato tasks for the Contrato.';
                        Visible = false;
                    }
                }
            }
        }
        area(factboxes)
        {
            part(Control1902018507; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Bill-to Customer No.");
                Visible = false;
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::Contrato),
                              "No." = field("No.");
            }
            part(Control1902136407; "Contrato No. of Prices FactBox")
            {
                ApplicationArea = Suite;
                SubPageLink = "No." = field("No."),
                              "Resource Filter" = field("Resource Filter"),
                              "Posting Date Filter" = field("Posting Date Filter"),
                              "Resource Gr. Filter" = field("Resource Gr. Filter"),
                              "Planning Date Filter" = field("Planning Date Filter");
                Visible = true;
            }
            part(Control1905650007; "ContratoWIP/RecognitionFactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No."),
                              "Resource Filter" = field("Resource Filter"),
                              "Posting Date Filter" = field("Posting Date Filter"),
                              "Resource Gr. Filter" = field("Resource Gr. Filter"),
                              "Planning Date Filter" = field("Planning Date Filter");
                Visible = false;
            }
            part("Contrato Details"; "Contrato Cost Factbox")
            {
                ApplicationArea = All;
                Caption = 'Contrato Details';
                SubPageLink = "No." = field("No.");
            }
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
                Caption = '&Contrato';
                Image = Job;
                action(ContratoPlanningLines)
                {
                    ApplicationArea = All;
                    Caption = 'Contrato &Planning Lines';
                    Image = JobLines;
                    ToolTip = 'View all planning lines for the Contrato. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a Contrato (Budget) or you can specify what you actually agreed with your customer that he should pay for the Contrato (Billable).';

                    trigger OnAction()
                    var
                        ContratoPlanningLine: Record "Contrato Planning Line";
                        ContratoPlanningLines: Page "Contrato Planning Lines";
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeContratoPlanningLinesAction(Rec, IsHandled);
                        if IsHandled then
                            exit;

                        Rec.TestField("No.");
                        ContratoPlanningLine.FilterGroup(2);
                        ContratoPlanningLine.SetRange("Contrato No.", Rec."No.");
                        ContratoPlanningLine.FilterGroup(0);
                        ContratoPlanningLines.SetContratoTaskNoVisible(true);
                        ContratoPlanningLines.SetTableView(ContratoPlanningLine);
                        ContratoPlanningLines.Editable := true;
                        ContratoPlanningLines.Run();
                    end;
                }
                action("&Dimensions")
                {
                    ApplicationArea = Dimensions;
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    RunObject = Page "Default Dimensions";
                    RunPageLink = "Table ID" = const(167),
                                  "No." = field("No.");
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, Contrato, or department, that you can assign to journal lines to distribute costs and analyze transaction history.';
                }
                action("&Statistics")
                {
                    ApplicationArea = All;
                    Caption = '&Statistics';
                    Image = Statistics;
                    RunObject = Page "Contrato Statistics";
                    RunPageLink = "No." = field("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View this Contrato''s statistics.';
                }
                action(TimeSheetLines)
                {
                    ApplicationArea = All;
                    Caption = 'Time Sheet Lines';
                    Image = LinesFromTimesheet;
                    ToolTip = 'View which time sheet lines are referencing this Contrato.';

                    trigger OnAction()
                    var
                        TimeSheetLine: Record "Time Sheet Line";
                        TimeSheetLineList: Page "Time Sheet Line List";
                    begin
                        TimeSheetLine.FilterGroup(2);
                        TimeSheetLine.SetRange(Type, TimeSheetLine.Type::Job);
                        TimeSheetLine.SetRange("Job No.", Rec."No.");
                        TimeSheetLine.SetRange(Posted, false);
                        TimeSheetLine.FilterGroup(0);

                        TimeSheetLineList.SetTableView(TimeSheetLine);
                        TimeSheetLineList.Run();
                    end;
                }
                action(SalesInvoicesCreditMemos)
                {
                    ApplicationArea = All;
                    Caption = 'Sales &Invoices/Credit Memos';
                    Image = GetSourceDoc;
                    ToolTip = 'View sales invoices or sales credit memos that are related to the selected Contrato.';

                    trigger OnAction()
                    var
                        ContratoInvoices: Page "Contrato Invoices";
                    begin
                        //ContratoInvoices.SetPrContrato(Rec);
                        ContratoInvoices.RunModal();
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
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Contrato),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action("&Online Map")
                {
                    ApplicationArea = All;
                    Caption = '&Online Map';
                    Image = Map;
                    ToolTip = 'View online map for addresses assigned to this Contrato.';

                    trigger OnAction()
                    begin
                        Rec.DisplayMap();
                    end;
                }
                action(Attachments)
                {
                    ApplicationArea = All;
                    Caption = 'Attachments';
                    Image = Attach;
                    ToolTip = 'Add a file as an attachment. You can attach images as well as documents.';

                    trigger OnAction()
                    var
                        DocumentAttachmentDetails: Page "Document Attachment Details";
                        RecRef: RecordRef;
                    begin
                        RecRef.GetTable(Rec);
                        DocumentAttachmentDetails.OpenForRecRef(RecRef);
                        DocumentAttachmentDetails.RunModal();
                    end;
                }
                action(AssemblyOrders)
                {
                    AccessByPermission = TableData "BOM Component" = R;
                    ApplicationArea = Assembly;
                    Caption = 'Assembly Orders';
                    Image = AssemblyOrder;
                    ToolTip = 'View ongoing assembly orders related to the Contrato. ';

                    trigger OnAction()
                    var
                        AssembleToOrderLink: Record "Assemble-to-OrderLinkContrato";
                    begin
                        //AssembleToOrderLink.ShowAsmOrders(Rec, '');
                    end;
                }
            }
            group("W&IP")
            {
                Caption = 'W&IP';
                Image = WIP;
                action("&WIP Entries")
                {
                    ApplicationArea = All;
                    Caption = '&WIP Entries';
                    Image = WIPEntries;
                    RunObject = Page "Contrato WIP Entries";
                    RunPageLink = "Contrato No." = field("No.");
                    RunPageView = sorting("Contrato No.", "Contrato Posting Group", "WIP Posting Date")
                                  order(descending);
                    ToolTip = 'View entries for the Contrato that are posted as work in process.';
                }
                action("WIP &G/L Entries")
                {
                    ApplicationArea = All;
                    Caption = 'WIP &G/L Entries';
                    Image = WIPLedger;
                    RunObject = Page "Contrato WIP G/L Entries";
                    RunPageLink = "Contrato No." = field("No.");
                    RunPageView = sorting("Contrato No.")
                                  order(descending);
                    ToolTip = 'View the Contrato''s WIP G/L entries.';
                }
            }
#if not CLEAN23
            group("&Prices")
            {
                Caption = '&Prices';
                Image = Price;
                Visible = not ExtendedPriceEnabled;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                ObsoleteTag = '17.0';
                action("&Resource")
                {
                    ApplicationArea = Suite;
                    Caption = '&Resource';
                    Image = Resource;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Contrato Resource Prices";
                    RunPageLink = "Contrato No." = field("No.");
                    ToolTip = 'View this Contrato''s resource prices.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
                action("&Item")
                {
                    ApplicationArea = Suite;
                    Caption = '&Item';
                    Image = Item;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Contrato Item Prices";
                    RunPageLink = "Contrato No." = field("No.");
                    ToolTip = 'View this Contrato''s item prices.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
                action("&G/L Account")
                {
                    ApplicationArea = Suite;
                    Caption = '&G/L Account';
                    Image = JobPrice;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Contrato G/L Account Prices";
                    RunPageLink = "Contrato No." = field("No.");
                    ToolTip = 'View this Contrato''s G/L account prices.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
            }
#endif
            group(Prices)
            {
                Caption = 'Prices & Discounts';
                Visible = ExtendedPriceEnabled;
                action(SalesPriceLists)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price Lists';
                    Image = Price;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up sales price lists for products that you sell to the customer. A product price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, Enum::"Price Type"::Sale, Enum::"Price Amount Type"::Any);
                    end;
                }
                action(SalesPriceLines)
                {
                    AccessByPermission = TableData "Sales Price Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Prices';
                    Image = Price;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up sales price lines for products that you sell to the customer. A product price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Sale);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Price);
                    end;
                }
                action(SalesDiscountLines)
                {
                    AccessByPermission = TableData "Sales Discount Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Discounts';
                    Image = LineDiscount;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up different discounts for products that you sell to the customer. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Sale);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Discount);
                    end;
                }
#if not CLEAN23
                action(SalesPriceListsDiscounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price Lists (Discounts)';
                    Image = LineDiscount;
                    Visible = false;
                    ToolTip = 'View or set up different discounts for products that you sell to the customer. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action SalesPriceLists shows all sales price lists with prices and discounts';
                    ObsoleteTag = '18.0';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, PriceType::Sale, AmountType::Discount);
                    end;
                }
#endif
                action(PurchasePriceLists)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Price Lists';
                    Image = ResourceCosts;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up purchase price lists for products that you buy from the vendor. An product price is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, Enum::"Price Type"::Purchase, Enum::"Price Amount Type"::Any);
                    end;
                }
                action(PurchPriceLines)
                {
                    AccessByPermission = TableData "Purchase Price Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Prices';
                    Image = Price;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up purchase price lines for products that you buy from the vendor. A product price is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Purchase);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Price);
                    end;
                }
                action(PurchDiscountLines)
                {
                    AccessByPermission = TableData "Purchase Discount Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Discounts';
                    Image = LineDiscount;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up different discounts for products that you buy from the vendor. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Purchase);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Discount);
                    end;
                }
#if not CLEAN23
                action(PurchasePriceListsDiscounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Price Lists (Discounts)';
                    Image = LineDiscount;
                    Visible = false;
                    ToolTip = 'View or set up different discounts for products that you buy from the vendor. An product discount is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action PurchasePriceLists shows all purchase price lists with prices and discounts';
                    ObsoleteTag = '18.0';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, PriceType::Purchase, AmountType::Discount);
                    end;
                }
#endif
            }
            group("Plan&ning")
            {
                Caption = 'Plan&ning';
                Image = Planning;
                action("Resource &Allocated per Contrato")
                {
                    ApplicationArea = All;
                    Caption = 'Resource &Allocated per Contrato';
                    Image = ViewJob;
                    RunObject = Page "ResourceAllocatedperContrato";
                    ToolTip = 'View this Contrato''s resource allocation.';
                }
                action("Res. Gr. All&ocated per Contrato")
                {
                    ApplicationArea = All;
                    Caption = 'Res. Gr. All&ocated per Contrato';
                    Image = ResourceGroup;
                    RunObject = Page "Res.Gr.AllocatedperContrato";
                    ToolTip = 'View the Contrato''s resource group allocation.';
                }
            }
            group(Warehouse_Related)
            {
                Caption = 'Warehouse';
                Image = Worksheets;
                action("Put-away/Pick Lines/Movement Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Put-away/Pick Lines/Movement Lines';
                    Image = PutawayLines;
                    ToolTip = 'View the list of ongoing inventory put-aways, picks, or movements for the Contrato.';

                    trigger OnAction()
                    var
                        WarehouseActivityLine: Record "Warehouse Activity Line";
                        WarehouseActivityLines: Page "Warehouse Activity Lines";
                    begin
                        WarehouseActivityLine.SetCurrentKey("Whse. Document No.", "Whse. Document Type", "Activity Type");
                        WarehouseActivityLine.SetRange("Whse. Document Type", WarehouseActivityLine."Whse. Document Type"::Job);
                        WarehouseActivityLine.SetRange("Whse. Document No.", Rec."No.");
                        if WarehouseActivityLine.IsEmpty() then begin
                            WarehouseActivityLine.Reset();
                            WarehouseActivityLine.SetCurrentKey("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.", "Unit of Measure Code", "Action Type", "Breakbulk No.", "Original Breakbulk");
                            WarehouseActivityLine.SetRange("Source Type", Database::Contrato);
                            WarehouseActivityLine.SetRange("Source Subtype", 0);
                            WarehouseActivityLine.SetRange("Source No.", Rec."No.");
                        end;
                        WarehouseActivityLines.SetTableView(WarehouseActivityLine);
                        WarehouseActivityLines.Run();
                    end;
                }
                action("Registered P&ick Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Registered Pick Lines';
                    Image = RegisteredDocs;
                    RunObject = Page "Registered Whse. Act.-Lines";
                    RunPageLink = "Source Type" = filter(167),
                                  "Source Subtype" = const("0"),
                                  "Source No." = field("No.");
                    RunPageView = sorting("Source Type", "Source Subtype", "Source No.", "Source Line No.", "Source Subline No.");
                    ToolTip = 'View the list of warehouse picks that have been made for the Contrato.';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Ledger E&ntries")
                {
                    ApplicationArea = All;
                    Caption = 'Ledger E&ntries';
                    Image = JobLedger;
                    RunObject = Page "Contrato Ledger Entries";
                    RunPageLink = "Contrato No." = field("No.");
                    RunPageView = sorting("Contrato No.", "Contrato Task No.", "Entry Type", "Posting Date")
                                  order(descending);
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
                action("Item Ledger Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    RunObject = Page "Item Ledger Entries";
                    RunPageLink = "Job No." = field("No.");
                    ToolTip = 'View the item ledger entries of items consumed by the Contrato.';
                }
                action("Whse. Ledger E&ntries")
                {
                    ApplicationArea = All;
                    Caption = 'Warehouse Entries';
                    Image = Warehouse;
                    RunObject = Page "Warehouse Entries";
                    RunPageLink = "Source Type" = filter(210 | 167),
                                    "Source No." = field("No.");
                    ToolTip = 'View the warehouse entries of items consumed by the Contrato.';
                }
            }
        }
        area(processing)
        {
            group("&Copy")
            {
                Caption = '&Copy';
                Image = Copy;
                action("Copy Contrato Tasks &from...")
                {
                    ApplicationArea = All;
                    Caption = 'Copy Contrato Tasks &from...';
                    Ellipsis = true;
                    Image = CopyToTask;
                    ToolTip = 'Open the Copy Contrato Tasks page.';

                    trigger OnAction()
                    var
                        CopyContratoTasks: Page "Copy Contrato Tasks";
                    begin
                        CopyContratoTasks.SetToContrato(Rec);
                        CopyContratoTasks.RunModal();
                    end;
                }
                action("Copy Contrato Tasks &to...")
                {
                    ApplicationArea = All;
                    Caption = 'Copy Contrato Tasks &to...';
                    Ellipsis = true;
                    Image = CopyFromTask;
                    ToolTip = 'Open the Copy Contratos To page.';

                    trigger OnAction()
                    var
                        CopyContratoTasks: Page "Copy Contrato Tasks";
                    begin
                        CopyContratoTasks.SetFromContrato(Rec);
                        CopyContratoTasks.RunModal();
                    end;
                }
            }
            group(Action26)
            {
                Caption = 'W&IP';
                Image = WIP;
                action("<Action82>")
                {
                    ApplicationArea = All;
                    Caption = '&Calculate WIP';
                    Ellipsis = true;
                    Image = CalculateWIP;
                    ToolTip = 'Run the Contrato Calculate WIP batch Contrato.';

                    trigger OnAction()
                    var
                        Contrato: Record Contrato;
                        ContratoCalculateWIP: Report "Contrato Calculate WIP";
                    begin
                        Rec.TestField(Rec."No.");
                        Contrato.Copy(Rec);
                        Contrato.SetRange("No.", Rec."No.");
                        ContratoCalculateWIP.SetTableView(Contrato);
                        ContratoCalculateWIP.Run();
                    end;
                }
                action("<Action83>")
                {
                    ApplicationArea = All;
                    Caption = '&Post WIP to G/L';
                    Ellipsis = true;
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Run the Contrato Post WIP to G/L batch Contrato.';

                    trigger OnAction()
                    var
                        Contrato: Record Contrato;
                    begin
                        Rec.TestField("No.");
                        Contrato.Copy(Rec);
                        Contrato.SetRange("No.", Rec."No.");
                        REPORT.RunModal(REPORT::"Contrato Post WIP to G/L", true, false, Contrato);
                    end;
                }
            }
            group(Warehouse)
            {
                Caption = 'Warehouse';
                Image = Worksheets;
                action("Create Inventory Pick")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Create Inventory Pick';
                    Image = CreateInventoryPick;
                    ToolTip = 'Create inventory picks for the item on the Contrato planning lines.';

                    trigger OnAction()
                    begin
                        FeatureTelemetry.LogUsage('0000GQU', 'Picks on Contratos', 'create inventory picks');
                        Rec.CreateInvtPutAwayPick();
                    end;
                }
                action("Create Warehouse Pick")
                {
                    AccessByPermission = TableData "Bin Content" = R;
                    ApplicationArea = Warehouse;
                    Caption = 'Create Warehouse Pick';
                    Image = CreateWarehousePick;
                    ToolTip = 'Create warehouse pick documents for the Contrato planning lines.';

                    trigger OnAction()
                    begin
                        FeatureTelemetry.LogUsage('0000GQV', 'Picks on Contratos', 'create warehouse picks');
                        Rec.CreateWarehousePick();
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action("Archive Contrato")
                {
                    ApplicationArea = All;
                    Caption = 'Archi&ve Contrato';
                    Image = Archive;
                    ToolTip = 'Send the Contrato to the archive. Later, you can restore the archived Contrato.';

                    trigger OnAction()
                    begin
                        ContratoArchiveManagement.ArchiveContrato(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(reporting)
        {
            action("Contrato Actual to Budget")
            {
                ApplicationArea = Suite;
                Caption = 'Contrato Actual to Budget';
                Image = "Report";
                RunObject = Report "Contrato Actual To Budget";
                ToolTip = 'Compare budgeted and usage amounts for selected Contratos. All lines of the selected Contrato show quantity, total cost, and line amount.';
                Visible = false;
            }
            action("Contrato Cost Budget")
            {
                ApplicationArea = All;
                Caption = 'Contrato Cost Budget';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Contrato Cost Budget";
                ToolTip = 'View the Contrato cost budgets for specific Contratos or for all Contratos. This report lists the step, task, and phase and the description of the activity. For each activity, the report includes the quantity, unit and total cost, and unit and total price.';
            }
            action("Contrato Analysis")
            {
                ApplicationArea = Suite;
                Caption = 'Contrato Analysis';
                Image = "Report";
                RunObject = Report "Contrato Analysis";
                ToolTip = 'Analyze the Contrato, such as the budgeted prices, usage prices, and billable prices, and then compares the three sets of prices.';
            }
            action("Contrato - Planning Lines")
            {
                ApplicationArea = Suite;
                Caption = 'Contrato - Planning Lines';
                Image = "Report";
                RunObject = Report "Contrato - Planning Lines";
                ToolTip = 'View all planning lines for the Contrato. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a Contrato (budget) or you can specify what you actually agreed with your customer that he should pay for the Contrato (billable).';
            }
            action("Contrato - Suggested Billing")
            {
                ApplicationArea = Suite;
                Caption = 'Contrato - Suggested Billing';
                Image = "Report";
                RunObject = Report "Contrato Suggested Billing";
                ToolTip = 'View a list of all Contratos, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
                Visible = false;
            }
            action("ContratoCostTransactionDetail")
            {
                ApplicationArea = All;
                Caption = 'Contrato Cost Transaction Detail';
                Image = "Report";
                RunObject = Report "ContratoCostTransactionDetail";
                ToolTip = 'List the details of your Contrato transactions. The report includes the Contrato number and description followed by a list of the transactions that occurred in the period you specify.';
            }
            action("Contrato Actual to Budget (Cost)")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget (Cost)';
                Image = "Report";
                RunObject = Report "ContratoActualtoBudget(Cost)";
                ToolTip = 'Compare the actual cost of your Contratos to the price that was budgeted. The report shows budget and actual amounts for each phase, task, and steps.';
            }
            action("Contrato Actual to Budget (Price)")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget (Price)';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "ContratoActualtoBudget(Price)";
                ToolTip = 'Compare the actual price of your Contratos to the price that was budgeted. The report shows budget and actual amounts for each phase, task, and steps.';
            }
            action("OpenPurchaseInvoicesbyContrato")
            {
                ApplicationArea = All;
                Caption = 'Open Purchase Invoices by Contrato';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "OpenPurchaseInvoicesbyContrato";
                ToolTip = 'View open purchase invoices by Contrato.';
            }
            action("Open Sales Invoices by Contrato")
            {
                ApplicationArea = All;
                Caption = 'Open Sales Invoices by Contrato';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "OpenSalesInvoicesbyContrato";
                ToolTip = 'View open sales invoices by Contrato.';
            }
            action("Contrato Cost Suggested Billing")
            {
                ApplicationArea = All;
                Caption = 'Contrato Cost Suggested Billing';
                Image = "Report";
                RunObject = Report "ContratoCostSuggestedBilling";
                ToolTip = 'Get suggestions on the amount you should bill a customer for a Contrato. The suggested billing is based on the actual cost of the Contrato less any amount that has already been invoiced to the customer.';
            }
            action("Report Contrato Quote")
            {
                ApplicationArea = Suite;
                Caption = 'Preview Contrato Quote';
                Image = "Report";
                ToolTip = 'Open the Contrato Quote report.';

                trigger OnAction()
                var
                    Contrato: Record Contrato;
                    ReportSelection: Record "Report Selections";
                begin
                    Contrato.SetCurrentKey("No.");
                    Contrato.SetRange("No.", Rec."No.");
                    ReportSelection.PrintWithDialogForCust(
                        ReportSelection.Usage::JQ, Contrato, true, Rec.FieldNo("Bill-to Customer No."));
                end;
            }
            action("Send Contrato Quote")
            {
                ApplicationArea = Suite;
                Caption = 'Send Contrato Quote';
                Image = SendTo;
                ToolTip = 'Send the Contrato quote to the customer. You can change the way that the document is sent in the window that appears.';

                trigger OnAction()
                begin
                    CODEUNIT.Run(CODEUNIT::"Contratos-Send", Rec);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Copy Contrato Tasks &from..._Promoted"; "Copy Contrato Tasks &from...")
                {
                }
                actionref("Copy Contrato Tasks &to..._Promoted"; "Copy Contrato Tasks &to...")
                {
                }
                actionref("Create Inventory Pick_Promoted"; "Create Inventory Pick")
                {
                }
                actionref("Create Warehouse Pick_Promoted"; "Create Warehouse Pick")
                {
                }
            }
            group(Category_Category8)
            {
                Caption = 'Print/Send', Comment = 'Generated from the PromotedActionCategories property index 7.';

                actionref("Report Contrato Quote_Promoted"; "Report Contrato Quote")
                {
                }
                actionref("Send Contrato Quote_Promoted"; "Send Contrato Quote")
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Prices & Discounts', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(SalesPriceLists_Promoted; SalesPriceLists)
                {
                }
                actionref(SalesPriceLines_Promoted; SalesPriceLines)
                {
                }
                actionref(PurchasePriceLists_Promoted; PurchasePriceLists)
                {
                }
                actionref(PurchPriceLines_Promoted; PurchPriceLines)
                {
                }
                actionref(SalesDiscountLines_Promoted; SalesDiscountLines)
                {
                }
                actionref(PurchDiscountLines_Promoted; PurchDiscountLines)
                {
                }
#if not CLEAN23
#pragma warning disable AL0432
                actionref(SalesPriceListsDiscounts_Promoted; SalesPriceListsDiscounts)
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action SalesPriceLists shows all sales price lists with prices and discounts';
                    ObsoleteTag = '18.0';
                }
#endif
#if not CLEAN23
#pragma warning disable AL0432
                actionref(PurchasePriceListsDiscounts_Promoted; PurchasePriceListsDiscounts)
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action PurchasePriceLists shows all purchase price lists with prices and discounts';
                    ObsoleteTag = '18.0';
                }
#endif
#if not CLEAN23
#pragma warning disable AL0432
                actionref("&Resource_Promoted"; "&Resource")
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
#endif
#if not CLEAN23
#pragma warning disable AL0432
                actionref("&Item_Promoted"; "&Item")
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
#endif
#if not CLEAN23
#pragma warning disable AL0432
                actionref("&G/L Account_Promoted"; "&G/L Account")
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
#endif
            }
            group(Category_Category5)
            {
                Caption = 'WIP', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref("<Action82>_Promoted"; "<Action82>")
                {
                }
                actionref("<Action83>_Promoted"; "<Action83>")
                {
                }
                actionref("&WIP Entries_Promoted"; "&WIP Entries")
                {
                }
                actionref("WIP &G/L Entries_Promoted"; "WIP &G/L Entries")
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Contrato', Comment = 'Generated from the PromotedActionCategories property index 6.';

                actionref("&Dimensions_Promoted"; "&Dimensions")
                {
                }
                actionref("&Statistics_Promoted"; "&Statistics")
                {
                }
                actionref("Ledger E&ntries_Promoted"; "Ledger E&ntries")
                {
                }
                actionref(Attachments_Promoted; Attachments)
                {
                }
                actionref("Co&mments_Promoted"; "Co&mments")
                {
                }

                separator(Navigate_Separator)
                {
                }

                actionref(ContratoPlanningLines_Promoted; ContratoPlanningLines)
                {
                }
                actionref(SalesInvoicesCreditMemos_Promoted; SalesInvoicesCreditMemos)
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Navigate', Comment = 'Generated from the PromotedActionCategories property index 5.';
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';

                actionref("Contrato Actual to Budget (Cost)_Promoted"; "Contrato Actual to Budget (Cost)")
                {
                }
                actionref("Contrato Analysis_Promoted"; "Contrato Analysis")
                {
                }
                actionref("Contrato - Planning Lines_Promoted"; "Contrato - Planning Lines")
                {
                }
                actionref("Contrato Cost Suggested Billing_Promoted"; "Contrato Cost Suggested Billing")
                {
                }
                actionref("Contrato Cost Transaction Detail_Promoted"; "ContratoCostTransactionDetail")
                {
                }
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
        ContratoTaskLinesEditable := Rec.CalcContratoTaskLinesEditable();
        CurrPage.ContratoTaskLines.Page.SetPerTaskBillingFieldsVisible(Rec."Task Billing Method" = Rec."Task Billing Method"::"Multiple customers");
        CurrPage.Update(false);
    end;

    var
        FormatAddress: Codeunit "Format Address";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ContratoArchiveManagement: Codeunit "Contrato Archive Management";
        EmptyShipToCodeErr: Label 'The Code field can only be empty if you select Custom Address in the Ship-to field.';
        NoFieldVisible: Boolean;
        ContratoTaskLinesEditable: Boolean;
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

    [IntegrationEvent(true, false)]
    local procedure OnBeforeContratoPlanningLinesAction(var Contrato: Record Contrato; var IsHandled: Boolean)
    begin
    end;
}

