//
//  OfferViewController.swift
//  BeaconSpot
//
//  Created by Sumit Jain on 27/04/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class OfferViewController: UIViewController {

	var UUID:String = "";
	
	@IBOutlet weak var titleLabel:UILabel!;
	@IBOutlet weak var descriptionLabel:UILabel!;
	@IBOutlet weak var offerImage:UIImageView!;
	@IBOutlet weak var spinner:UIActivityIndicatorView!;
	
    override func viewDidLoad() {
        super.viewDidLoad()
		titleLabel.text = "";
		descriptionLabel.text = "";
        // Do any additional setup after loading the view.
		spinner.startAnimating();
		getOfferDetails();
    }
	
	private func getOfferDetails()
	{
		let url:String = "http://54.209.128.238:4000/uuid/" + UUID;// 7677887666-9888-897hhh-iishiuhd-nsjkjhks
		let offerUrl:NSURL = NSURL(string: url)!;
		let request = NSMutableURLRequest(URL: offerUrl, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 20.0);
		request.HTTPMethod = "GET";
		
		let session = NSURLSession.sharedSession();
		let datatask = session.dataTaskWithRequest(request) { (data, response, error) in
			
			if let httpResponse = response as? NSHTTPURLResponse{
				if(httpResponse.statusCode == 200)
				{
					print(data, separator: "", terminator: "\n");
					self.processOffer(data!);
				}
				else
				{
					dispatch_async(dispatch_get_main_queue(), {
						self.descriptionLabel.text = "No Offer Available";
						self.offerImage.image = UIImage(named: "noOffer");
					});

				}
			}
			else
			{
				dispatch_async(dispatch_get_main_queue(), {
					self.descriptionLabel.text = "No Offer Available";
					self.offerImage.image = UIImage(named: "noOffer");
				});
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.spinner.stopAnimating();
			})
		}
		datatask.resume();
	}
	
	private func processOffer(data:NSData)
	{
		do
		{
			let jsonObject = try NSJSONSerialization.JSONObjectWithData(data as NSData, options: NSJSONReadingOptions.MutableContainers) as? NSArray;
			if(jsonObject?.count > 0)
			{
				let offerDictionary = jsonObject?.objectAtIndex(0) as! [String:AnyObject];
				updateUI(offerDictionary);
			}
			else
			{
				dispatch_async(dispatch_get_main_queue(), {
					self.descriptionLabel.text = "No Offer Available";
					self.offerImage.image = UIImage(named: "noOffer");
				});
			}
			
		}
		catch let error as NSError
		{
			print(error.description);
		}
	}

	private func updateUI(offer:[String:AnyObject])
	{
		dispatch_async(dispatch_get_main_queue())
		{
			self.descriptionLabel.text = offer["offer"] as? String;
		}
		
		dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
			if let imageURL = offer["image_url"] as? String{
				if let imageNSURL:NSURL = NSURL(string: imageURL)
				{
					let data:NSData = NSData(contentsOfURL: imageNSURL)!;
					if(data.length != 0)
					{
						if let image:UIImage = UIImage(data: data){
							dispatch_async(dispatch_get_main_queue(), {
								self.offerImage.image = image;
							})
						}
						else
						{
							dispatch_async(dispatch_get_main_queue(), {
								self.offerImage.image = UIImage(named: "noOffer");
							})
						}
					}
					else
					{
						dispatch_async(dispatch_get_main_queue(), {
							self.offerImage.image = UIImage(named: "noOffer");
						})
					}
				}
			}
			else
			{
				dispatch_async(dispatch_get_main_queue(), {
					self.offerImage.image = UIImage(named: "noOffer");
				})
			}
		}
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func doneButtonTapped(sender:UIButton)
	{
		self.dismissViewControllerAnimated(true, completion: nil);
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
